import '../models/crop_recommendation.dart';

/// Pure-Dart implementation of the crop recommendation engine.
/// Mirrors the logic of the Spring Boot CropAdvisorService.
/// Wire this to the REST API when backend is deployed.
class CropAdvisorService {
  static final CropAdvisorService _instance = CropAdvisorService._();
  factory CropAdvisorService() => _instance;
  CropAdvisorService._();

  /// Returns up to 5 ranked crop recommendations.
  List<CropRecommendation> recommend({
    required SoilType soil,
    required WaterAvailability water,
    required String region, // e.g. "Madurai", "Thanjavur"
  }) {
    final all = _allCrops();

    // Filter by soil and water compatibility, then score
    final scored = <_ScoredCrop>[];
    for (final c in all) {
      int score = 0;

      // ── Soil compatibility ───────────────────────────────────────────────
      if (c.suitableSoils.contains(soil)) score += 40;
      else if (c.suitableSoils.length >= 3) score += 10; // adaptable crop

      // ── Water compatibility ──────────────────────────────────────────────
      if (c.rec.waterNeed == water.label) score += 35;
      else if (water == WaterAvailability.high && c.rec.waterNeed == 'Medium') score += 15;
      else if (water == WaterAvailability.medium && c.rec.waterNeed == 'Low') score += 10;

      // ── Region-specific bonus ────────────────────────────────────────────
      final lowerRegion = region.toLowerCase();
      if (c.preferredRegions.any((r) => lowerRegion.contains(r.toLowerCase()) || r.toLowerCase().contains(lowerRegion))) {
        score += 15;
      }

      // ── Price trend bonus ────────────────────────────────────────────────
      if (c.rec.priceTrend == 'Rising') score += 10;
      if (c.rec.confidenceScore > 75) score += 5;

      if (score >= 40) {
        scored.add(_ScoredCrop(crop: c.rec, score: score));
      }
    }

    // Sort by score descending, take top 5
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(5).map((s) => _withConfidence(s)).toList();
  }

  CropRecommendation _withConfidence(_ScoredCrop s) {
    final conf = (s.score * 100 ~/ 100).clamp(0, 100);
    return CropRecommendation(
      cropName: s.crop.cropName,
      emoji: s.crop.emoji,
      soilMatch: s.crop.soilMatch,
      waterNeed: s.crop.waterNeed,
      growingDurationWeeks: s.crop.growingDurationWeeks,
      bestSowingMonths: s.crop.bestSowingMonths,
      minPriceRs: s.crop.minPriceRs,
      maxPriceRs: s.crop.maxPriceRs,
      priceTrend: s.crop.priceTrend,
      reason: s.crop.reason,
      confidenceScore: conf,
    );
  }

  // ── Crop knowledge base ──────────────────────────────────────────────────────
  List<_CropEntry> _allCrops() => [
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Paddy', emoji: '🌾',
        soilMatch: 'Clay / Alluvial, Loamy', waterNeed: 'High',
        growingDurationWeeks: 20, bestSowingMonths: 'June–July / Nov–Dec',
        minPriceRs: 1900, maxPriceRs: 2400,
        priceTrend: 'Stable', confidenceScore: 90,
        reason: 'Paddy thrives in high-water clay soils. MSP protected and consistent demand.',
      ),
      suitableSoils: [SoilType.clay, SoilType.loamy],
      preferredRegions: ['Thanjavur', 'Tiruvarur', 'Nagapattinam', 'Tirunelveli'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Tomato', emoji: '🍅',
        soilMatch: 'Loamy, Red', waterNeed: 'Medium',
        growingDurationWeeks: 12, bestSowingMonths: 'Jul–Aug / Nov–Dec',
        minPriceRs: 1200, maxPriceRs: 4500,
        priceTrend: 'Rising', confidenceScore: 78,
        reason: 'Rising demand over 3 years. Good for loamy soils with drip irrigation.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.red],
      preferredRegions: ['Madurai', 'Coimbatore', 'Vellore', 'Salem'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Onion', emoji: '🧅',
        soilMatch: 'Loamy, Red', waterNeed: 'Medium',
        growingDurationWeeks: 16, bestSowingMonths: 'Oct–Nov / Jan–Feb',
        minPriceRs: 1400, maxPriceRs: 4000,
        priceTrend: 'Rising', confidenceScore: 80,
        reason: 'Price trend is rising year-on-year. Well-drained loamy soil essential.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.red],
      preferredRegions: ['Madurai', 'Dindigul', 'Salem', 'Tiruppur'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Cotton', emoji: '🌿',
        soilMatch: 'Black Soil', waterNeed: 'Medium',
        growingDurationWeeks: 24, bestSowingMonths: 'May–Jun',
        minPriceRs: 5500, maxPriceRs: 8000,
        priceTrend: 'Stable', confidenceScore: 82,
        reason: 'Black soil is ideal for cotton. Consistent MSP and export demand.',
      ),
      suitableSoils: [SoilType.black],
      preferredRegions: ['Madurai', 'Virudhunagar', 'Tirunelveli', 'Coimbatore'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Groundnut', emoji: '🥜',
        soilMatch: 'Red, Sandy, Loamy', waterNeed: 'Low',
        growingDurationWeeks: 20, bestSowingMonths: 'Jun–Jul / Nov–Dec',
        minPriceRs: 4800, maxPriceRs: 7100,
        priceTrend: 'Rising', confidenceScore: 85,
        reason: 'Drought-tolerant. Red and sandy soils give excellent yield. Price rising.',
      ),
      suitableSoils: [SoilType.red, SoilType.sandy, SoilType.loamy],
      preferredRegions: ['Vellore', 'Tiruvannamalai', 'Salem', 'Krishnagiri'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Sugarcane', emoji: '🎋',
        soilMatch: 'Loamy, Clay', waterNeed: 'High',
        growingDurationWeeks: 52, bestSowingMonths: 'Jan–Feb / Dec',
        minPriceRs: 2800, maxPriceRs: 4000,
        priceTrend: 'Stable', confidenceScore: 75,
        reason: 'Government MSP ensures price stability. Needs heavy irrigation and fertile soil.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.clay],
      preferredRegions: ['Madurai', 'Erode', 'Tirupur', 'Cuddalore'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Maize', emoji: '🌽',
        soilMatch: 'Loamy, Red', waterNeed: 'Medium',
        growingDurationWeeks: 16, bestSowingMonths: 'Jun–Jul / Jan–Feb',
        minPriceRs: 1800, maxPriceRs: 4400,
        priceTrend: 'Rising', confidenceScore: 76,
        reason: 'Poultry feed demand driving price up. Suitable for most soil types.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.red, SoilType.black],
      preferredRegions: ['Madurai', 'Dharmapuri', 'Salem', 'Erode'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Black Gram', emoji: '🫘',
        soilMatch: 'Red, Loamy', waterNeed: 'Low',
        growingDurationWeeks: 10, bestSowingMonths: 'Sep–Oct',
        minPriceRs: 6000, maxPriceRs: 8500,
        priceTrend: 'Rising', confidenceScore: 83,
        reason: 'High protein demand. Short duration crop with rising MSP every year.',
      ),
      suitableSoils: [SoilType.red, SoilType.loamy],
      preferredRegions: ['Villupuram', 'Cuddalore', 'Tiruvarur', 'Pudukkottai'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Green Gram', emoji: '🫛',
        soilMatch: 'Sandy, Red, Loamy', waterNeed: 'Low',
        growingDurationWeeks: 10, bestSowingMonths: 'Mar–Apr / Jun–Jul',
        minPriceRs: 6500, maxPriceRs: 9000,
        priceTrend: 'Rising', confidenceScore: 80,
        reason: 'Short-duration pulse. Drought tolerant. Demand from dal mills is strong.',
      ),
      suitableSoils: [SoilType.sandy, SoilType.red, SoilType.loamy],
      preferredRegions: ['Ramanathapuram', 'Virudhunagar', 'Dindigul'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Banana', emoji: '🍌',
        soilMatch: 'Loamy, Clay', waterNeed: 'High',
        growingDurationWeeks: 44, bestSowingMonths: 'All year',
        minPriceRs: 1200, maxPriceRs: 3800,
        priceTrend: 'Rising', confidenceScore: 77,
        reason: 'Year-round crop. Alluvial and loamy banks ideal. Growing export market.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.clay],
      preferredRegions: ['Trichy', 'Erode', 'Theni', 'Namakkal'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Turmeric', emoji: '🟡',
        soilMatch: 'Loamy, Red, Laterite', waterNeed: 'Medium',
        growingDurationWeeks: 36, bestSowingMonths: 'Apr–May',
        minPriceRs: 5500, maxPriceRs: 12000,
        priceTrend: 'Rising', confidenceScore: 88,
        reason: 'Export-driven price surge. Erode is the world turmeric capital. High returns.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.red, SoilType.laterite],
      preferredRegions: ['Erode', 'Coimbatore', 'Salem', 'Dharmapuri'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Sesame', emoji: '🌱',
        soilMatch: 'Sandy, Red', waterNeed: 'Low',
        growingDurationWeeks: 12, bestSowingMonths: 'Jul–Aug / Dec–Jan',
        minPriceRs: 8000, maxPriceRs: 14000,
        priceTrend: 'Rising', confidenceScore: 79,
        reason: 'Oil export demand high. Very drought-tolerant. Excellent for sandy-red soils.',
      ),
      suitableSoils: [SoilType.sandy, SoilType.red],
      preferredRegions: ['Krishnagiri', 'Dharmapuri', 'Vellore'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Brinjal', emoji: '🍆',
        soilMatch: 'Loamy, Sandy Loam', waterNeed: 'Medium',
        growingDurationWeeks: 16, bestSowingMonths: 'Jun–Jul / Nov–Dec',
        minPriceRs: 1300, maxPriceRs: 3200,
        priceTrend: 'Stable', confidenceScore: 72,
        reason: 'Consistent vegetable demand. Multiple harvests per season. Good for loamy soil.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.sandy],
      preferredRegions: ['Coimbatore', 'Erode', 'Tirupur', 'Madurai'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Sunflower', emoji: '🌻',
        soilMatch: 'Black, Loamy', waterNeed: 'Medium',
        growingDurationWeeks: 16, bestSowingMonths: 'Oct–Nov / Feb–Mar',
        minPriceRs: 3000, maxPriceRs: 6000,
        priceTrend: 'Rising', confidenceScore: 74,
        reason: 'Oilseed demand rising. Short duration, fits well in black and loamy soils.',
      ),
      suitableSoils: [SoilType.black, SoilType.loamy],
      preferredRegions: ['Vellore', 'Tiruvannamalai', 'Krishnagiri'],
    ),
    _CropEntry(
      rec: const CropRecommendation(
        cropName: 'Chilli', emoji: '🌶️',
        soilMatch: 'Loamy, Red, Sandy', waterNeed: 'Medium',
        growingDurationWeeks: 20, bestSowingMonths: 'Jun–Jul / Nov–Dec',
        minPriceRs: 3200, maxPriceRs: 9500,
        priceTrend: 'Rising', confidenceScore: 81,
        reason: 'Export demand and spice processing driving up prices. Hot market outlook.',
      ),
      suitableSoils: [SoilType.loamy, SoilType.red, SoilType.sandy],
      preferredRegions: ['Madurai', 'Ramanathapuram', 'Dindigul', 'Virudhunagar'],
    ),
  ];
}

class _CropEntry {
  final CropRecommendation rec;
  final List<SoilType> suitableSoils;
  final List<String> preferredRegions;
  const _CropEntry({
    required this.rec,
    required this.suitableSoils,
    required this.preferredRegions,
  });
}

class _ScoredCrop {
  final CropRecommendation crop;
  final int score;
  const _ScoredCrop({required this.crop, required this.score});
}
