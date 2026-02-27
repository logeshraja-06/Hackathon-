// ============================================================
// CropAdvisorController.java — Spring Boot REST Controller
// ============================================================
package com.agriapp.advisor.controller;

import com.agriapp.advisor.dto.RecommendationRequest;
import com.agriapp.advisor.dto.RecommendationResponse;
import com.agriapp.advisor.service.CropAdvisorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/advisor")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CropAdvisorController {

    private final CropAdvisorService advisorService;

    /**
     * POST /api/v1/advisor/recommend
     * Body: { "soilType":"BLACK", "waterAvailability":"MEDIUM", "region":"Madurai" }
     * Returns: top 5 crop recommendations sorted by match score
     */
    @PostMapping("/recommend")
    public ResponseEntity<List<RecommendationResponse>> recommend(
            @Valid @RequestBody RecommendationRequest request) {
        List<RecommendationResponse> results = advisorService.recommend(request);
        return ResponseEntity.ok(results);
    }

    /**
     * GET /api/v1/advisor/soils
     * Returns all available soil types
     */
    @GetMapping("/soils")
    public ResponseEntity<?> getSoilTypes() {
        return ResponseEntity.ok(advisorService.getAllSoilTypes());
    }

    /**
     * GET /api/v1/advisor/crops/{cropId}/history?region=Madurai
     * Returns 3-year monthly price history for a crop
     */
    @GetMapping("/crops/{cropId}/history")
    public ResponseEntity<?> getCropPriceHistory(
            @PathVariable Long cropId,
            @RequestParam(required = false) String region) {
        return ResponseEntity.ok(advisorService.getCropPriceHistory(cropId, region));
    }
}

// ============================================================
// RecommendationRequest.java — Request DTO
// ============================================================
package com.agriapp.advisor.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RecommendationRequest {
    @NotBlank
    private String soilType;           // "RED", "BLACK", "SANDY", "CLAY", "LOAMY", "LATERITE"

    @NotBlank
    private String waterAvailability;  // "HIGH", "MEDIUM", "LOW"

    private String region;             // optional: "Madurai", "Thanjavur"
}

// ============================================================
// RecommendationResponse.java — Response DTO
// ============================================================
package com.agriapp.advisor.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class RecommendationResponse {
    private Long   cropId;
    private String cropName;
    private String emoji;
    private String category;
    private String waterNeed;
    private String soilMatch;
    private int    growingWeeksMin;
    private int    growingWeeksMax;
    private String bestSowingMonths;
    private double forecastMinPrice;   // ₹/quintal
    private double forecastMaxPrice;
    private String priceTrend;         // "Rising" | "Stable" | "Falling"
    private int    confidenceScore;    // 0-100
    private String advisoryNote;
    private int    matchScore;
}

// ============================================================
// CropAdvisorService.java — Service Layer
// ============================================================
package com.agriapp.advisor.service;

import com.agriapp.advisor.dto.RecommendationRequest;
import com.agriapp.advisor.dto.RecommendationResponse;
import com.agriapp.advisor.model.*;
import com.agriapp.advisor.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class CropAdvisorService {

    private final CropRepository               cropRepo;
    private final SoilTypeRepository           soilRepo;
    private final CropSoilCompatibilityRepo    soilCompatRepo;
    private final CropRegionRepository         regionRepo;
    private final MarketPriceTrendRepository   trendRepo;
    private final RecommendationRequestRepository reqRepo;
    private final RecommendationResultRepository  resRepo;

    public List<RecommendationResponse> recommend(RecommendationRequest request) {
        // 1. Persist the request for analytics
        RecommendationRequestEntity req = reqRepo.save(RecommendationRequestEntity.builder()
            .soilTypeCode(request.getSoilType())
            .waterNeed(request.getWaterAvailability())
            .region(request.getRegion())
            .build());

        // 2. Find soil entity
        SoilType soil = soilRepo.findByCode(request.getSoilType().toUpperCase())
            .orElseThrow(() -> new IllegalArgumentException("Unknown soil type: " + request.getSoilType()));

        // 3. Load all compatible crops for this soil
        List<CropSoilCompatibility> compatible = soilCompatRepo
            .findBySoilIdAndSuitabilityGreaterThan(soil.getId(), 40);

        // 4. Score each crop
        List<ScoredCrop> scored = new ArrayList<>();
        for (CropSoilCompatibility csc : compatible) {
            Crop crop = csc.getCrop();
            int score = 0;

            // Soil score
            score += csc.getSuitability() * 40 / 100;

            // Water score
            if (crop.getWaterNeed().equalsIgnoreCase(request.getWaterAvailability())) {
                score += 35;
            } else if ("HIGH".equals(request.getWaterAvailability())
                    && "MEDIUM".equals(crop.getWaterNeed().toUpperCase())) {
                score += 15;
            } else if ("MEDIUM".equals(request.getWaterAvailability())
                    && "LOW".equals(crop.getWaterNeed().toUpperCase())) {
                score += 10;
            }

            // Region score
            if (request.getRegion() != null && !request.getRegion().isBlank()) {
                boolean regionMatch = regionRepo
                    .existsByCropIdAndRegionNameContainingIgnoreCase(crop.getId(), request.getRegion());
                if (regionMatch) score += 15;
            }

            // Market trend score
            trendRepo.findByCropId(crop.getId()).ifPresent(trend -> {
                // already captured in outer variable via lambda — workaround with holder
            });
            Optional<MarketPriceTrend> trendOpt = trendRepo.findByCropId(crop.getId());
            if (trendOpt.isPresent()) {
                MarketPriceTrend t = trendOpt.get();
                if ("Rising".equals(t.getTrend())) score += 10;
                if (t.getConfidencePct() > 75) score += 5;
            }

            if (score >= 40) {
                scored.add(new ScoredCrop(crop, trendOpt.orElse(null), score));
            }
        }

        // 5. Sort by score, take top 5
        scored.sort(Comparator.comparingInt(ScoredCrop::score).reversed());
        List<ScoredCrop> top5 = scored.subList(0, Math.min(5, scored.size()));

        // 6. Persist results
        List<RecommendationResultEntity> results = new ArrayList<>();
        for (int i = 0; i < top5.size(); i++) {
            results.add(RecommendationResultEntity.builder()
                .requestId(req.getId())
                .cropId(top5.get(i).crop().getId())
                .rank(i + 1)
                .matchScore(top5.get(i).score())
                .build());
        }
        resRepo.saveAll(results);

        // 7. Map to response DTOs
        return top5.stream().map(sc -> {
            MarketPriceTrend t = sc.trend();
            return RecommendationResponse.builder()
                .cropId(sc.crop().getId())
                .cropName(sc.crop().getName())
                .emoji(sc.crop().getEmoji())
                .category(sc.crop().getCategory())
                .waterNeed(sc.crop().getWaterNeed())
                .soilMatch(soil.getName())
                .growingWeeksMin(sc.crop().getGrowingWeeksMin())
                .growingWeeksMax(sc.crop().getGrowingWeeksMax())
                .bestSowingMonths(sc.crop().getBestSowingMonths())
                .forecastMinPrice(t != null ? t.getForecastMin6mo() : 0)
                .forecastMaxPrice(t != null ? t.getForecastMax6mo() : 0)
                .priceTrend(t != null ? t.getTrend() : "Stable")
                .confidenceScore(sc.score())
                .advisoryNote(buildAdvisoryNote(sc.crop(), t))
                .matchScore(sc.score())
                .build();
        }).toList();
    }

    private String buildAdvisoryNote(Crop crop, MarketPriceTrend trend) {
        String base = crop.getName() + " suits " + crop.getWaterNeed().toLowerCase() + " water conditions. ";
        if (trend != null && "Rising".equals(trend.getTrend())) {
            base += "Price has been rising — good market outlook for next 3-6 months.";
        } else if (trend != null && "Falling".equals(trend.getTrend())) {
            base += "Price is declining — consider crop diversification.";
        } else {
            base += "Market price is stable. Consistent demand expected.";
        }
        return base;
    }

    public List<SoilType> getAllSoilTypes() {
        return soilRepo.findAll();
    }

    public List<MarketPriceHistory> getCropPriceHistory(Long cropId, String region) {
        if (region != null && !region.isBlank()) {
            return historyRepo.findByCropIdAndRegionNameContainingIgnoreCaseOrderByPriceDateAsc(cropId, region);
        }
        return historyRepo.findByCropIdOrderByPriceDateAsc(cropId);
    }

    record ScoredCrop(Crop crop, MarketPriceTrend trend, int score) {}
}

// ============================================================
// application.properties — Spring Boot Config
// ============================================================
/*
spring.datasource.url=jdbc:mysql://localhost:3306/crop_advisor_db?useSSL=false&serverTimezone=Asia/Kolkata
spring.datasource.username=root
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
server.port=8080
*/

// ============================================================
// Flutter API call snippet (replace mock with real endpoint)
// In: lib/services/crop_advisor_service.dart
// ============================================================
/*
import 'package:http/http.dart' as http;
import 'dart:convert';

const _baseUrl = 'http://localhost:8080/api/v1/advisor';

Future<List<CropRecommendation>> fetchFromBackend({
  required String soilType,      // 'RED', 'BLACK', etc.
  required String water,         // 'HIGH', 'MEDIUM', 'LOW'
  required String region,
}) async {
  final res = await http.post(
    Uri.parse('$_baseUrl/recommend'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'soilType': soilType,
      'waterAvailability': water,
      'region': region,
    }),
  );
  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body);
    return data.map((j) => CropRecommendation.fromBackendJson(j)).toList();
  }
  throw Exception('Failed to load recommendations: ${res.statusCode}');
}
*/
