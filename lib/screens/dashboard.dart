import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../services/mock_api.dart';
import '../models/crop.dart';
import '../widgets/crop_tile.dart';
import '../widgets/location_input.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToRecommendations;
  const DashboardScreen({Key? key, required this.onNavigateToRecommendations}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Crop> _crops = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final location = Provider.of<FarmerState>(context, listen: false).location;
    final crops = await MockApi().fetchDemand(location);
    if (mounted) {
      setState(() {
        _crops = crops;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${state.get('dashboard')} - ${state.name}'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LocationInput(
              initialLocation: state.location,
              onLocationChanged: (val) {
                state.updateProfile(state.name, val, state.language);
                _fetchData();
              },
            ),
            const SizedBox(height: 24),
            Text(
              state.get('high_demand'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _crops.isEmpty 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _crops.length,
                    itemBuilder: (context, index) {
                      return CropTile(crop: _crops[index]);
                    },
                  ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onNavigateToRecommendations,
                child: Text(
                  state.get('get_recommendations'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
