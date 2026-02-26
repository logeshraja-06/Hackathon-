import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/crop.dart';
import '../models/buyer.dart';

class MockApi {
  static final MockApi _instance = MockApi._internal();
  factory MockApi() => _instance;
  MockApi._internal();

  List<Crop> _crops = [];
  List<Buyer> _buyers = [];
  Timer? _updateTimer;

  Future<void> init() async {
    await _loadData();
    _startPeriodicUpdates();
  }

  Future<void> _loadData() async {
    try {
      final cropsString = await rootBundle.loadString('assets/data/sample_demand.json');
      final buyersString = await rootBundle.loadString('assets/data/sample_buyers.json');
      
      final List<dynamic> cropsJson = jsonDecode(cropsString);
      final List<dynamic> buyersJson = jsonDecode(buyersString);

      _crops = cropsJson.map((c) => Crop.fromJson(c)).toList();
      _buyers = buyersJson.map((b) => Buyer.fromJson(b)).toList();
    } catch (e) {
      print('Error loading mock data: $e');
    }
  }

  // Timer-driven update simulating real-time perturbations in demand/prices
  // UI can poll (e.g., using Timer.periodic in the screen) to get fresh values.
  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final random = Random();
      _crops = _crops.map((crop) {
        final demandPerturb = random.nextInt(11) - 5; // -5 to +5
        final pricePerturb = (random.nextDouble() * 10) - 5; // -5 to +5
        
        final newDemand = (crop.demandScore + demandPerturb).clamp(0, 100);
        final newPrice = (crop.avgPrice + pricePerturb).clamp(1.0, 1000.0);
        
        // Add new price to trend, drop oldest
        final newTrend = List<double>.from(crop.trend);
        newTrend.removeAt(0);
        newTrend.add(newPrice);
        
        return Crop(
          id: crop.id,
          name: crop.name,
          demandScore: newDemand,
          avgPrice: newPrice,
          trend: newTrend,
        );
      }).toList();
    });
  }

  Future<List<Crop>> fetchDemand(String location) async {
    // Return all for demo, sorting by demand score descending
    final list = List<Crop>.from(_crops);
    list.sort((a, b) => b.demandScore.compareTo(a.demandScore));
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchRecommendations(String location) async {
    final list = List<Crop>.from(_crops);
    final results = <Map<String, dynamic>>[];

    for (var crop in list) {
      // Recommendation algorithm:
      // Final Score = (Demand% * 0.5) + (NormalizedPrice * 0.3) + (TrendSlope * 0.2)
      // Here simplified:
      final trendSlope = crop.trend.last - crop.trend.first;
      final score = (crop.demandScore * 0.5) + (crop.avgPrice * 0.1) + (trendSlope * 2);
      
      List<String> reasons = [];
      if (crop.demandScore > 80) reasons.add('High Demand');
      if (trendSlope > 0) reasons.add('Rising Price');
      
      results.add({
        'crop': crop,
        'score': score,
        'reasons': reasons.isEmpty ? ['Stable Market'] : reasons,
      });
    }

    results.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return results.take(5).toList();
  }

  Future<List<Buyer>> fetchBuyers(String? cropId, String location) async {
    if (cropId == null) {
      return List<Buyer>.from(_buyers);
    }
    return _buyers.where((b) => b.cropsInterested.contains(cropId)).toList();
  }
}
