import 'dart:async';
import 'dart:math';
import '../models/soil_report.dart';

class SoilAiService {
  static final SoilAiService _instance = SoilAiService._internal();
  factory SoilAiService() => _instance;
  SoilAiService._internal();

  // Simulates OCR processing of a Soil Health Card image.
  // We now accept the imagePath from the camera/gallery picker.
  Future<SoilReport> simulateOCR({String? imagePath}) async {
    // Artificial 2-second delay for "scanning" inference
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app we would send the image file to the ML API.
    // For now, based on the fact an image was passed or mock triggered, return random but realistic Tamil Nadu mock parameters.
    
    // Simulate varying soil types
    final rand = Random();
    double ph = 5.5 + rand.nextDouble() * 3.0; // 5.5 to 8.5
    double n = 100.0 + rand.nextDouble() * 100.0; // 100 to 200
    double p = 15.0 + rand.nextDouble() * 30.0; // 15 to 45
    double k = 120.0 + rand.nextDouble() * 150.0; // 120 to 270

    // Simple AI Crop Predictor logic based on generated NPK and pH ranges
    List<String> suggestedCrops = [];
    if (ph >= 6.0 && ph <= 7.0 && n > 130) {
      suggestedCrops.add('Samba Rice (சம்பா நெல்)');
    }
    if (ph >= 6.5 && p >= 25) {
      suggestedCrops.add('Sugarcane (கரும்பு)');
    }
    if (ph <= 7.5 && k > 150) {
      suggestedCrops.add('Banana (வாழை)');
    }
    if (n < 140 && p < 25) {
      suggestedCrops.add('Groundnut (நிலக்கடலை)');
    }
    if (suggestedCrops.isEmpty) {
       suggestedCrops.add('Turmeric (மஞ்சள்)');
    }

    return SoilReport(
      id: 'DOC-${rand.nextInt(9000)+1000}',
      phLevel: ph,
      ecLevel: 0.5 + rand.nextDouble() * 1.5,
      organicCarbon: 0.4 + rand.nextDouble() * 0.8,
      nitrogen: n,
      phosphorus: p,
      potassium: k,
      dateTested: DateTime.now().subtract(Duration(days: rand.nextInt(30))),
      recommendedCrops: suggestedCrops,
    );
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
    
    // Dynamic simulated "Real-Time" alerts based on the current hour
    if (isDelta || location == 'Chennai' || location == 'Coimbatore') {
      final hour = DateTime.now().hour;
      
      if (hour >= 6 && hour < 12) {
         return "🔴 URGENT (Morning Update): Mettur Dam releasing 25,000 cusecs. Heavy monsoon runoff expected. Do NOT deploy basal fertilizers today.";
      } else if (hour >= 12 && hour < 18) {
         return "⚠️ CAUTION (Afternoon Update): Vaigai Dam levels rising. 10,000 cusecs scheduled for release. Monitor soil moisture.";
      } else {
         return "ℹ️ INFO (Evening Update): River flow stabilizing. Safe to proceed with scheduled urea application tomorrow morning.";
      }
    }
    
    return null;
  }
}
