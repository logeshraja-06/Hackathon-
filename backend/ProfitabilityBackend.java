// ============================================================
// ProfitabilityController.java — Spring Boot REST Controller
// POST /api/v1/profit/calculate
// GET  /api/v1/profit/crops          → list all crops with cost data
// GET  /api/v1/profit/crops/{id}/baseline
// ============================================================
package com.agriapp.profit.controller;

import com.agriapp.profit.dto.ProfitRequest;
import com.agriapp.profit.dto.ProfitResponse;
import com.agriapp.profit.service.ProfitabilityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/profit")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProfitabilityController {

    private final ProfitabilityService profitService;

    /** POST /api/v1/profit/calculate
     *  Body: { "cropId": 1, "landAreaAcres": 2.5 }  */
    @PostMapping("/calculate")
    public ResponseEntity<ProfitResponse> calculate(@Valid @RequestBody ProfitRequest req) {
        return ResponseEntity.ok(profitService.calculate(req));
    }

    /** GET /api/v1/profit/crops  — all crops that have a cost baseline */
    @GetMapping("/crops")
    public ResponseEntity<List<?>> listCrops() {
        return ResponseEntity.ok(profitService.getAllCropsWithBaseline());
    }

    /** GET /api/v1/profit/crops/{id}/baseline  — get per-acre cost data */
    @GetMapping("/crops/{id}/baseline")
    public ResponseEntity<?> getBaseline(@PathVariable Long id) {
        return ResponseEntity.ok(profitService.getBaseline(id));
    }
}

// ============================================================
// ProfitRequest.java
// ============================================================
package com.agriapp.profit.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ProfitRequest {
    @NotNull
    private Long cropId;

    @NotNull @Positive
    private Double landAreaAcres;         // always pass in acres; frontend converts hectares

    private Long farmerId;                // optional, for logging
}

// ============================================================
// ProfitResponse.java
// ============================================================
package com.agriapp.profit.dto;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class ProfitResponse {
    private String cropName;
    private String emoji;
    private double landAreaAcres;

    // Cost breakdown
    private double seedCost;
    private double fertilizerCost;
    private double pesticideCost;
    private double laborCost;
    private double irrigationCost;
    private double otherCost;
    private double totalCost;

    // Income
    private double expectedYieldQuintals;
    private double marketPricePerQuintal;
    private double grossIncome;

    // Profit
    private double netProfit;
    private double profitMarginPct;
    private double roiPct;
    private String assessment;           // "Excellent"|"Good"|"Moderate"|"Poor"
}

// ============================================================
// ProfitabilityService.java
// ============================================================
package com.agriapp.profit.service;

import com.agriapp.profit.dto.*;
import com.agriapp.advisor.model.*;
import com.agriapp.advisor.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProfitabilityService {

    private final CropRepository         cropRepo;
    private final CropCostBaselineRepo   baselineRepo;
    private final ProfitCalcLogRepo      logRepo;

    public ProfitResponse calculate(ProfitRequest req) {
        // 1. Load crop + baseline
        Crop crop = cropRepo.findById(req.getCropId())
            .orElseThrow(() -> new IllegalArgumentException("Crop not found: " + req.getCropId()));

        CropCostBaseline b = baselineRepo.findTopByCropIdOrderByReferenceYearDesc(req.getCropId())
            .orElseThrow(() -> new IllegalArgumentException("No cost data for crop: " + req.getCropId()));

        double acres = req.getLandAreaAcres();

        // 2. Scale per-acre costs
        double seed       = round(b.getSeedCostPerAcre()       * acres);
        double fertilizer = round(b.getFertilizerCostPerAcre() * acres);
        double pesticide  = round(b.getPesticideCostPerAcre()  * acres);
        double labor      = round(b.getLaborCostPerAcre()       * acres);
        double irrigation = round(b.getIrrigationCostPerAcre() * acres);
        double other      = round(b.getOtherCostPerAcre()       * acres);
        double total      = round(seed + fertilizer + pesticide + labor + irrigation + other);

        // 3. Compute income
        double yield  = round(b.getExpectedYieldQuintalsPerAcre() * acres);
        double price  = b.getMarketPricePerQuintal().doubleValue();
        double gross  = round(yield * price);
        double net    = round(gross - total);
        double roi    = total > 0 ? round((net / total) * 100) : 0;
        double margin = gross > 0 ? round((net / gross) * 100) : 0;
        String assess = roi >= 80 ? "Excellent" : roi >= 40 ? "Good" : roi >= 10 ? "Moderate" : "Poor";

        // 4. Persist log
        logRepo.save(ProfitCalcLog.builder()
            .farmerId(req.getFarmerId()).cropId(req.getCropId())
            .landAreaAcres(acres).seedCost(seed).fertilizerCost(fertilizer)
            .pesticideCost(pesticide).laborCost(labor).irrigationCost(irrigation)
            .otherCost(other).totalCost(total).expectedYieldQuintals(yield)
            .marketPricePerQuintal(price).grossIncome(gross).netProfit(net)
            .roiPct(roi).profitMarginPct(margin).assessment(assess).build());

        return ProfitResponse.builder()
            .cropName(crop.getName()).emoji(crop.getEmoji())
            .landAreaAcres(acres)
            .seedCost(seed).fertilizerCost(fertilizer).pesticideCost(pesticide)
            .laborCost(labor).irrigationCost(irrigation).otherCost(other)
            .totalCost(total).expectedYieldQuintals(yield)
            .marketPricePerQuintal(price).grossIncome(gross)
            .netProfit(net).profitMarginPct(margin).roiPct(roi).assessment(assess)
            .build();
    }

    public List<Crop> getAllCropsWithBaseline() {
        return baselineRepo.findAllDistinctCrops();
    }

    public CropCostBaseline getBaseline(Long cropId) {
        return baselineRepo.findTopByCropIdOrderByReferenceYearDesc(cropId)
            .orElseThrow();
    }

    private double round(double v) {
        return BigDecimal.valueOf(v).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }
}

// ============================================================
// Flutter API hook — swap ProfitCalculatorService.calculate()
// with this HTTP call when backend is running:
// ============================================================
/*
Future<ProfitReport> fetchFromBackend(String cropId, double landAreaAcres) async {
  final res = await http.post(
    Uri.parse('http://localhost:8080/api/v1/profit/calculate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'cropId': cropId, 'landAreaAcres': landAreaAcres}),
  );
  if (res.statusCode == 200) {
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    return ProfitReport(
      cropName: j['cropName'], emoji: j['emoji'],
      landAreaAcres: j['landAreaAcres'],
      seedCost: j['seedCost'], fertilizerCost: j['fertilizerCost'],
      pesticideCost: j['pesticideCost'], laborCost: j['laborCost'],
      irrigationCost: j['irrigationCost'], otherCost: j['otherCost'],
      totalCost: j['totalCost'], expectedYieldQuintals: j['expectedYieldQuintals'],
      marketPricePerQuintal: j['marketPricePerQuintal'],
      grossIncome: j['grossIncome'], netProfit: j['netProfit'],
      profitMarginPct: j['profitMarginPct'], roiPct: j['roiPct'],
      assessment: j['assessment'],
    );
  }
  throw Exception('Backend error: ${res.statusCode}');
}
*/
