import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/crop.dart';
import '../models/market_price.dart';
import '../models/local_product.dart';
import '../models/crop_demand.dart';
import '../models/crop_history.dart';

class MockApi {
  static final MockApi _instance = MockApi._internal();
  factory MockApi() => _instance;
  MockApi._internal();

  List<Crop> _crops = [];
  List<MarketPrice> _marketPrices = [];
  List<LocalProduct> _localProducts = [];
  List<FarmerEntry> _farmerEntries = [];
  List<CropHistory> _cropHistories = [];
  Timer? _updateTimer;

  Future<void> init() async {
    await _loadData();
    _startPeriodicUpdates();
  }

  Future<void> _loadData() async {
    try {
      final cropsString = await rootBundle.loadString('assets/data/sample_demand.json');
      final marketsString = await rootBundle.loadString('assets/data/market_prices.json');
      final productsString = await rootBundle.loadString('assets/data/local_products.json');
      final farmersString = await rootBundle.loadString('assets/data/farmers_data.json');
      final historyString = await rootBundle.loadString('assets/data/crop_history.json');

      _crops = (jsonDecode(cropsString) as List).map((c) => Crop.fromJson(c)).toList();
      _marketPrices = (jsonDecode(marketsString) as List).map((m) => MarketPrice.fromJson(m)).toList();
      _localProducts = (jsonDecode(productsString) as List).map((p) => LocalProduct.fromJson(p)).toList();
      _farmerEntries = (jsonDecode(farmersString) as List).map((f) => FarmerEntry.fromJson(f)).toList();
      _cropHistories = (jsonDecode(historyString) as List).map((h) => CropHistory.fromJson(h as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading mock data: $e');
    }
  }

  /// Returns the crop history for [cropName], case-insensitive. Returns null if not found.
  CropHistory? getCropHistory(String cropName) {
    try {
      return _cropHistories.firstWhere(
        (h) => h.cropName.toLowerCase() == cropName.toLowerCase(),
      );
    } catch (_) {
      return null;
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

  Future<List<MarketPrice>> fetchMarketPrices(String location) async {
    return List<MarketPrice>.from(_marketPrices);
  }

  /// Groups farmer entries by (region, cropName), counts them,
  /// and returns color-coded [CropDemandResult] for the given region.
  /// Falls back to ALL regions if [region] is empty or has no matches.
  List<CropDemandResult> analyzeDemand(String region) {
    // Try region-specific first; fallback to all entries
    List<FarmerEntry> entries = region.isEmpty
        ? _farmerEntries
        : _farmerEntries.where((e) =>
            e.region.toLowerCase().contains(region.toLowerCase().split(',')[0].trim()) ||
            region.toLowerCase().contains(e.region.toLowerCase())).toList();

    if (entries.isEmpty) entries = _farmerEntries;

    // Group by cropName → aggregate count and total area
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final e in entries) {
      final key = e.cropName.toLowerCase();
      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'cropName': e.cropName,
          'count': 0,
          'totalArea': 0.0,
          'harvestMonth': e.harvestMonth,
          'region': e.region,
        };
      }
      grouped[key]!['count'] = (grouped[key]!['count'] as int) + 1;
      grouped[key]!['totalArea'] = (grouped[key]!['totalArea'] as double) + e.landArea;
    }

    // Map to CropDemandResult with appropriate level
    final results = grouped.values.map((g) {
      final count = g['count'] as int;
      DemandLevel level;
      if (count >= 10) {
        level = DemandLevel.high;
      } else if (count >= 5) {
        level = DemandLevel.moderate;
      } else {
        level = DemandLevel.low;
      }
      return CropDemandResult(
        cropName: g['cropName'] as String,
        region: g['region'] as String,
        count: count,
        totalArea: g['totalArea'] as double,
        harvestMonth: g['harvestMonth'] as String,
        level: level,
      );
    }).toList();

    // Sort: high first, then by count desc
    results.sort((a, b) => b.count.compareTo(a.count));
    return results;
  }

  Future<List<LocalProduct>> fetchLocalProducts(String userLocation, String searchQuery) async {
    List<LocalProduct> results;

    // If user is searching, ignore location and search ALL products
    if (searchQuery.isNotEmpty) {
      final lowerQ = searchQuery.toLowerCase();
      results = _localProducts.where((p) =>
          p.name.toLowerCase().contains(lowerQ) ||
          p.category.toLowerCase().contains(lowerQ) ||
          p.location.toLowerCase().contains(lowerQ)).toList();
      return results;
    }

    // Location filter: try to match products to the user's district
    if (userLocation.isNotEmpty) {
      final lowerLoc = userLocation.toLowerCase();
      // Check both directions: does location contain product's district OR does product's district contain location?
      results = _localProducts.where((p) =>
          lowerLoc.contains(p.location.toLowerCase()) ||
          p.location.toLowerCase().contains(lowerLoc.split(',')[0].trim())
      ).toList();

      // Fallback: if no location match, show ALL products so user always sees something
      if (results.isEmpty) {
        results = List<LocalProduct>.from(_localProducts);
      }
    } else {
      // No location set — show all
      results = List<LocalProduct>.from(_localProducts);
    }

    return results;
  }
}
