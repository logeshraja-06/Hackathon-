class Buyer {
  final String id;
  final String name;
  final List<String> cropsInterested;
  final double distanceKm;
  final String contact;

  Buyer({
    required this.id,
    required this.name,
    required this.cropsInterested,
    required this.distanceKm,
    required this.contact,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] as String,
      name: json['name'] as String,
      cropsInterested: List<String>.from(json['cropsInterested']),
      distanceKm: (json['distanceKm'] as num).toDouble(),
      contact: json['contact'] as String,
    );
  }
}
