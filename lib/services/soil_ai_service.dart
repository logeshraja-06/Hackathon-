import 'dart:async';
import 'dart:math';
import '../models/soil_report.dart';

class SoilAiService {
  static final SoilAiService _instance = SoilAiService._internal();
  factory SoilAiService() => _instance;
  SoilAiService._internal();

  // Simulates OCR processing of a Soil Health Card image
  // In a real app, this would upload the image to a Spring Boot backend
  // which runs OCR and returns the extracted JSON.
  Future<SoilReport> simulateOCR() async {
    // Artificial 2-second delay for "scanning"
    await Future.delayed(const Duration(seconds: 2));
    
    // Return a mock parsed report
    return SoilReport.demo();
  }

  // AI-Driven Fertilizer Recommendation
  // FR = (Target Yield - Soil Nutrient Supply) / Fertilizer Efficiency
  Map<String, dynamic> calculateFertilizer(SoilReport report, String cropType) {
    // Simplified Mock Constants for 'Samba Rice' in Tamil Nadu
    double targetYieldN = 150.0; // Required Nitrogen kg/ha for good yield
    double targetYieldP = 50.0;
    double targetYieldK = 50.0;
    
    // Fertilizer Efficiency constants (e.g. Urea is ~46% N, but plant uptake efficiency is ~40%)
    double efficiencyN = 0.40;
    double efficiencyP = 0.20;
    double efficiencyK = 0.60;

    // Calculate required nutrients (kg/ha)
    // If soil has more than target, requirement is 0
    double reqN = max(0, (targetYieldN - (report.nitrogen * 0.5)) / efficiencyN);
    double reqP = max(0, (targetYieldP - (report.phosphorus * 0.5)) / efficiencyP);
    double reqK = max(0, (targetYieldK - (report.potassium * 0.5)) / efficiencyK);

    // Convert raw nutrient requirements to actual commercial fertilizer bags (approx 50kg bags)
    // Urea (46% N)
    int ureaBags = (reqN / 0.46 / 50).ceil();
    // DAP (18% N, 46% P) -> Simplified ignoring N contribution for MVP
    int dapBags = (reqP / 0.46 / 50).ceil();
    // MOP (60% K)
    int mopBags = (reqK / 0.60 / 50).ceil();

    return {
      'urea_bags': ureaBags,
      'dap_bags': dapBags,
      'mop_bags': mopBags,
      'notes': 'Calculated for $cropType based on uploaded Soil Health Card.',
    };
  }

  // Hyper-Local Weather/Dam API Mock
  Future<String?> getDamReleaseAlert(String location) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For MVP, if location is in Delta, randomly trigger an alert
    final deltaRegions = ['thanjavur', 'trichy', 'tiruvarur', 'nagapattinam', 'cauvery', 'vaigai'];
    final locLower = location.toLowerCase();
    
    bool isDelta = deltaRegions.any((region) => locLower.contains(region));
    
    // Hardcoded to always show an alert for demo purposes if located in delta or fallback
    if (isDelta || location == 'Chennai' || location == 'Coimbatore') {
         return "⚠️ Mettur Dam Alert: 15,000 cusecs released. Postpone basal fertilizer application to avoid runoff.";
    }
    
    return null;
  }
}
