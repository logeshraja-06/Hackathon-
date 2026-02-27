class CropCostData {
  final String cropName;
  final String emoji;
  final double seedCostPerAcre;           // ₹
  final double fertilizerCostPerAcre;     // ₹
  final double pesticideCostPerAcre;      // ₹
  final double laborCostPerAcre;          // ₹
  final double irrigationCostPerAcre;     // ₹
  final double otherCostPerAcre;          // ₹
  final double expectedYieldQuintalsPerAcre;
  final double marketPricePerQuintal;     // current/predicted ₹
  final String unit;                      // 'quintal', 'dozen', 'kg'

  const CropCostData({
    required this.cropName,
    required this.emoji,
    required this.seedCostPerAcre,
    required this.fertilizerCostPerAcre,
    required this.pesticideCostPerAcre,
    required this.laborCostPerAcre,
    required this.irrigationCostPerAcre,
    required this.otherCostPerAcre,
    required this.expectedYieldQuintalsPerAcre,
    required this.marketPricePerQuintal,
    this.unit = 'quintal',
  });

  double get totalCostPerAcre =>
      seedCostPerAcre + fertilizerCostPerAcre + pesticideCostPerAcre +
      laborCostPerAcre + irrigationCostPerAcre + otherCostPerAcre;
}

class ProfitReport {
  final String cropName;
  final String emoji;
  final double landAreaAcres;

  // Cost breakdown
  final double seedCost;
  final double fertilizerCost;
  final double pesticideCost;
  final double laborCost;
  final double irrigationCost;
  final double otherCost;
  final double totalCost;

  // Income
  final double expectedYieldQuintals;
  final double marketPricePerQuintal;
  final double grossIncome;

  // Profit
  final double netProfit;
  final double profitMarginPct;
  final double roiPct;           // Return on Investment %
  final String assessment;       // 'Excellent', 'Good', 'Moderate', 'Poor'

  const ProfitReport({
    required this.cropName,
    required this.emoji,
    required this.landAreaAcres,
    required this.seedCost,
    required this.fertilizerCost,
    required this.pesticideCost,
    required this.laborCost,
    required this.irrigationCost,
    required this.otherCost,
    required this.totalCost,
    required this.expectedYieldQuintals,
    required this.marketPricePerQuintal,
    required this.grossIncome,
    required this.netProfit,
    required this.profitMarginPct,
    required this.roiPct,
    required this.assessment,
  });
}
