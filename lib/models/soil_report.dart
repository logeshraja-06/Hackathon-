class SoilReport {
  final String id;
  final double phLevel;
  final double ecLevel;
  final double organicCarbon;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final DateTime dateTested;

  SoilReport({
    required this.id,
    required this.phLevel,
    required this.ecLevel,
    required this.organicCarbon,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.dateTested,
  });

  factory SoilReport.demo() {
    return SoilReport(
      id: 'TN-SHC-847291',
      phLevel: 7.2, // Slightly alkaline, common in some delta areas
      ecLevel: 0.8, // Normal salinity
      organicCarbon: 0.45, // Low-Medium
      nitrogen: 120.0, // Low (kg/ha)
      phosphorus: 15.0, // Medium (kg/ha)
      potassium: 250.0, // High (kg/ha)
      dateTested: DateTime.now().subtract(const Duration(days: 5)),
    );
  }
}
