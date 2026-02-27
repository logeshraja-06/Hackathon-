class CropYearData {
  final int year;
  final double avgPrice;
  final double peakPrice;
  final double lowPrice;
  final double totalProductionTons;
  final List<double> monthlyPrices; // 12 values Jan→Dec

  const CropYearData({
    required this.year,
    required this.avgPrice,
    required this.peakPrice,
    required this.lowPrice,
    required this.totalProductionTons,
    required this.monthlyPrices,
  });

  factory CropYearData.fromJson(Map<String, dynamic> j) => CropYearData(
        year: j['year'] as int,
        avgPrice: (j['avgPrice'] as num).toDouble(),
        peakPrice: (j['peakPrice'] as num).toDouble(),
        lowPrice: (j['lowPrice'] as num).toDouble(),
        totalProductionTons: (j['totalProductionTons'] as num).toDouble(),
        monthlyPrices: (j['monthlyPrices'] as List)
            .map((v) => (v as num).toDouble())
            .toList(),
      );
}

class CropHistory {
  final String cropName;
  final String region;
  final String unit;
  final List<CropYearData> years;

  const CropHistory({
    required this.cropName,
    required this.region,
    required this.unit,
    required this.years,
  });

  factory CropHistory.fromJson(Map<String, dynamic> j) => CropHistory(
        cropName: j['cropName'] as String,
        region: j['region'] as String,
        unit: j['unit'] as String,
        years: (j['years'] as List)
            .map((y) => CropYearData.fromJson(y as Map<String, dynamic>))
            .toList(),
      );
}
