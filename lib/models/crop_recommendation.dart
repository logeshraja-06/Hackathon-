/// A single crop recommendation result returned by the advisor.
class CropRecommendation {
  final String cropName;
  final String emoji;
  final String soilMatch;
  final String waterNeed;
  final int growingDurationWeeks; // total weeks from sowing to harvest
  final String bestSowingMonths;  // e.g. "June–July"
  final int minPriceRs;           // estimated market price range (₹/quintal)
  final int maxPriceRs;
  final String priceTrend;        // 'Rising', 'Stable', 'Falling'
  final String reason;            // short advisory note
  final int confidenceScore;      // 0–100

  const CropRecommendation({
    required this.cropName,
    required this.emoji,
    required this.soilMatch,
    required this.waterNeed,
    required this.growingDurationWeeks,
    required this.bestSowingMonths,
    required this.minPriceRs,
    required this.maxPriceRs,
    required this.priceTrend,
    required this.reason,
    required this.confidenceScore,
  });

  String get durationLabel {
    final months = growingDurationWeeks ~/ 4;
    final rem = growingDurationWeeks % 4;
    if (months == 0) return '$growingDurationWeeks weeks';
    if (rem == 0) return '$months month${months > 1 ? "s" : ""}';
    return '$months month${months > 1 ? "s" : ""} $rem weeks';
  }

  String get priceRange => '₹$minPriceRs – ₹$maxPriceRs / quintal';
}

enum SoilType {
  red('Red Soil', 'Slightly acidic, good drainage, low moisture retention'),
  black('Black Soil (Regur)', 'High clay, excellent moisture retention, nutrient-rich'),
  sandy('Sandy Soil', 'Well-drained, low nutrients, dries quickly'),
  clay('Clay / Alluvial Soil', 'Heavy, high water retention, fertile'),
  loamy('Loamy Soil', 'Balanced texture, best for most crops'),
  laterite('Laterite Soil', 'Iron-rich, acidic, good drainage');

  const SoilType(this.label, this.description);
  final String label;
  final String description;
}

enum WaterAvailability {
  high('High', 'Reliable irrigation or high rainfall'),
  medium('Medium', 'Seasonal irrigation or moderate rainfall'),
  low('Low', 'Rain-fed only or scarce water');

  const WaterAvailability(this.label, this.description);
  final String label;
  final String description;
}
