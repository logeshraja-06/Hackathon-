class FarmerEntry {
  final String farmerName;
  final String region;
  final String cropName;
  final String harvestMonth;
  final double landArea;

  FarmerEntry({
    required this.farmerName,
    required this.region,
    required this.cropName,
    required this.harvestMonth,
    required this.landArea,
  });

  factory FarmerEntry.fromJson(Map<String, dynamic> json) {
    return FarmerEntry(
      farmerName: json['farmerName'] as String,
      region: json['region'] as String,
      cropName: json['cropName'] as String,
      harvestMonth: json['harvestMonth'] as String,
      landArea: (json['landArea'] as num).toDouble(),
    );
  }
}

enum DemandLevel { high, moderate, low }

class CropDemandResult {
  final String cropName;
  final String region;
  final int count;        // number of farmers growing this crop in this region
  final double totalArea; // total land area
  final String harvestMonth;
  final DemandLevel level;

  CropDemandResult({
    required this.cropName,
    required this.region,
    required this.count,
    required this.totalArea,
    required this.harvestMonth,
    required this.level,
  });

  String get message {
    switch (level) {
      case DemandLevel.high:
        return 'High supply expected. Possible price drop.';
      case DemandLevel.moderate:
        return 'Moderate supply. Monitor market trends.';
      case DemandLevel.low:
        return 'Low supply expected. Good price potential.';
    }
  }
}
