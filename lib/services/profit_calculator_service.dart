import '../models/crop_profit.dart';

class ProfitCalculatorService {
  static final ProfitCalculatorService _i = ProfitCalculatorService._();
  factory ProfitCalculatorService() => _i;
  ProfitCalculatorService._();

  // ── Per-acre baseline data (Tamil Nadu averages, 2024–25) ────────────────────
  static const List<CropCostData> _cropData = [
    CropCostData(
      cropName: 'Paddy', emoji: '🌾',
      seedCostPerAcre: 1200, fertilizerCostPerAcre: 4500,
      pesticideCostPerAcre: 1800, laborCostPerAcre: 8000,
      irrigationCostPerAcre: 3500, otherCostPerAcre: 1000,
      expectedYieldQuintalsPerAcre: 25, marketPricePerQuintal: 2100,
    ),
    CropCostData(
      cropName: 'Tomato', emoji: '🍅',
      seedCostPerAcre: 2500, fertilizerCostPerAcre: 6000,
      pesticideCostPerAcre: 3500, laborCostPerAcre: 10000,
      irrigationCostPerAcre: 4000, otherCostPerAcre: 2000,
      expectedYieldQuintalsPerAcre: 120, marketPricePerQuintal: 1500,
    ),
    CropCostData(
      cropName: 'Onion', emoji: '🧅',
      seedCostPerAcre: 3000, fertilizerCostPerAcre: 5500,
      pesticideCostPerAcre: 2500, laborCostPerAcre: 9000,
      irrigationCostPerAcre: 3500, otherCostPerAcre: 1500,
      expectedYieldQuintalsPerAcre: 80, marketPricePerQuintal: 1800,
    ),
    CropCostData(
      cropName: 'Cotton', emoji: '🌿',
      seedCostPerAcre: 1800, fertilizerCostPerAcre: 5000,
      pesticideCostPerAcre: 4500, laborCostPerAcre: 7000,
      irrigationCostPerAcre: 2500, otherCostPerAcre: 1200,
      expectedYieldQuintalsPerAcre: 12, marketPricePerQuintal: 6200,
    ),
    CropCostData(
      cropName: 'Groundnut', emoji: '🥜',
      seedCostPerAcre: 4000, fertilizerCostPerAcre: 3500,
      pesticideCostPerAcre: 2000, laborCostPerAcre: 6500,
      irrigationCostPerAcre: 2000, otherCostPerAcre: 1000,
      expectedYieldQuintalsPerAcre: 8, marketPricePerQuintal: 5500,
    ),
    CropCostData(
      cropName: 'Sugarcane', emoji: '🎋',
      seedCostPerAcre: 5000, fertilizerCostPerAcre: 7000,
      pesticideCostPerAcre: 2500, laborCostPerAcre: 12000,
      irrigationCostPerAcre: 6000, otherCostPerAcre: 2500,
      expectedYieldQuintalsPerAcre: 400, marketPricePerQuintal: 340,
    ),
    CropCostData(
      cropName: 'Maize', emoji: '🌽',
      seedCostPerAcre: 1500, fertilizerCostPerAcre: 4000,
      pesticideCostPerAcre: 1500, laborCostPerAcre: 5000,
      irrigationCostPerAcre: 2000, otherCostPerAcre: 800,
      expectedYieldQuintalsPerAcre: 20, marketPricePerQuintal: 2100,
    ),
    CropCostData(
      cropName: 'Black Gram', emoji: '🫘',
      seedCostPerAcre: 1200, fertilizerCostPerAcre: 2500,
      pesticideCostPerAcre: 1200, laborCostPerAcre: 4500,
      irrigationCostPerAcre: 1500, otherCostPerAcre: 600,
      expectedYieldQuintalsPerAcre: 5, marketPricePerQuintal: 7000,
    ),
    CropCostData(
      cropName: 'Green Gram', emoji: '🫛',
      seedCostPerAcre: 1300, fertilizerCostPerAcre: 2500,
      pesticideCostPerAcre: 1000, laborCostPerAcre: 4000,
      irrigationCostPerAcre: 1200, otherCostPerAcre: 500,
      expectedYieldQuintalsPerAcre: 4, marketPricePerQuintal: 7500,
    ),
    CropCostData(
      cropName: 'Banana', emoji: '🍌',
      seedCostPerAcre: 8000, fertilizerCostPerAcre: 8000,
      pesticideCostPerAcre: 3000, laborCostPerAcre: 12000,
      irrigationCostPerAcre: 5000, otherCostPerAcre: 2000,
      expectedYieldQuintalsPerAcre: 200, marketPricePerQuintal: 1200,
    ),
    CropCostData(
      cropName: 'Turmeric', emoji: '🟡',
      seedCostPerAcre: 12000, fertilizerCostPerAcre: 6000,
      pesticideCostPerAcre: 2500, laborCostPerAcre: 10000,
      irrigationCostPerAcre: 4000, otherCostPerAcre: 2000,
      expectedYieldQuintalsPerAcre: 20, marketPricePerQuintal: 8000,
    ),
    CropCostData(
      cropName: 'Sesame', emoji: '🌱',
      seedCostPerAcre: 800, fertilizerCostPerAcre: 2000,
      pesticideCostPerAcre: 800, laborCostPerAcre: 4000,
      irrigationCostPerAcre: 1000, otherCostPerAcre: 400,
      expectedYieldQuintalsPerAcre: 3, marketPricePerQuintal: 11000,
    ),
    CropCostData(
      cropName: 'Brinjal', emoji: '🍆',
      seedCostPerAcre: 2000, fertilizerCostPerAcre: 5000,
      pesticideCostPerAcre: 3000, laborCostPerAcre: 8000,
      irrigationCostPerAcre: 3000, otherCostPerAcre: 1500,
      expectedYieldQuintalsPerAcre: 100, marketPricePerQuintal: 1400,
    ),
    CropCostData(
      cropName: 'Chilli', emoji: '🌶️',
      seedCostPerAcre: 3000, fertilizerCostPerAcre: 6500,
      pesticideCostPerAcre: 4000, laborCostPerAcre: 11000,
      irrigationCostPerAcre: 4000, otherCostPerAcre: 2000,
      expectedYieldQuintalsPerAcre: 15, marketPricePerQuintal: 5000,
    ),
    CropCostData(
      cropName: 'Sunflower', emoji: '🌻',
      seedCostPerAcre: 1000, fertilizerCostPerAcre: 3000,
      pesticideCostPerAcre: 1200, laborCostPerAcre: 4500,
      irrigationCostPerAcre: 1800, otherCostPerAcre: 700,
      expectedYieldQuintalsPerAcre: 7, marketPricePerQuintal: 4500,
    ),
  ];

  List<String> get allCropNames => _cropData.map((c) => c.cropName).toList();

  CropCostData? getCostData(String cropName) {
    try {
      return _cropData.firstWhere(
        (c) => c.cropName.toLowerCase() == cropName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  ProfitReport calculate({
    required String cropName,
    required double landAreaAcres,
  }) {
    final data = getCostData(cropName);
    if (data == null) throw Exception('No cost data for crop: $cropName');

    // Scale per-acre costs by land area
    final seed        = data.seedCostPerAcre        * landAreaAcres;
    final fertilizer  = data.fertilizerCostPerAcre  * landAreaAcres;
    final pesticide   = data.pesticideCostPerAcre   * landAreaAcres;
    final labor       = data.laborCostPerAcre        * landAreaAcres;
    final irrigation  = data.irrigationCostPerAcre  * landAreaAcres;
    final other       = data.otherCostPerAcre        * landAreaAcres;
    final total       = data.totalCostPerAcre        * landAreaAcres;

    // Yield & income
    final yield       = data.expectedYieldQuintalsPerAcre * landAreaAcres;
    final price       = data.marketPricePerQuintal;
    final gross       = yield * price;
    final net         = gross - total;
    final margin      = gross > 0 ? (net / gross) * 100 : 0.0;
    final roi         = total > 0 ? (net / total) * 100 : 0.0;

    String assess;
    if (roi >= 80) assess = 'Excellent';
    else if (roi >= 40) assess = 'Good';
    else if (roi >= 10) assess = 'Moderate';
    else assess = 'Poor';

    return ProfitReport(
      cropName: cropName, emoji: data.emoji,
      landAreaAcres: landAreaAcres,
      seedCost: seed, fertilizerCost: fertilizer,
      pesticideCost: pesticide, laborCost: labor,
      irrigationCost: irrigation, otherCost: other,
      totalCost: total,
      expectedYieldQuintals: yield,
      marketPricePerQuintal: price,
      grossIncome: gross,
      netProfit: net,
      profitMarginPct: margin,
      roiPct: roi,
      assessment: assess,
    );
  }
}
