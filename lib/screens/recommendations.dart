import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../services/mock_api.dart';
import '../models/crop.dart';

class RecommendationsScreen extends StatefulWidget {
  final Function(String) onSeeBuyers;
  const RecommendationsScreen({Key? key, required this.onSeeBuyers}) : super(key: key);

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  List<Map<String, dynamic>> _recs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecs();
  }

  Future<void> _loadRecs() async {
    final location = Provider.of<FarmerState>(context, listen: false).location;
    final recs = await MockApi().fetchRecommendations(location);
    if (mounted) {
      setState(() {
        _recs = recs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(state.get('recommendations')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recs.length,
            itemBuilder: (context, index) {
              final rec = _recs[index];
              final Crop crop = rec['crop'];
              final List<String> reasons = rec['reasons'];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(crop.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Score: ${(rec['score'] as double).toStringAsFixed(1)}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: reasons.map((r) => Chip(
                          label: Text(r, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green.shade100,
                        )).toList(),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100), 
                      minimumSize: const Size(80, 48)
                    ),
                    onPressed: () => widget.onSeeBuyers(crop.id),
                    child: Text(state.get('see_buyers'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          ),
    );
  }
}
