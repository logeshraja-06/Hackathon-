class Crop {
  final String id;
  final String name;
  final int demandScore;
  final double avgPrice;
  final List<double> trend;

  Crop({
    required this.id,
    required this.name,
    required this.demandScore,
    required this.avgPrice,
    required this.trend,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] as String,
      name: json['name'] as String,
      demandScore: json['demandScore'] as int,
      avgPrice: (json['avgPrice'] as num).toDouble(),
      trend: (json['trend'] as List).map((e) => (e as num).toDouble()).toList(),
    );
  }
}
