import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../services/mock_api.dart';
import '../models/crop_demand.dart';
import '../widgets/location_input.dart';
import '../widgets/crop_history_popup.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToRecommendations;
  const DashboardScreen({Key? key, required this.onNavigateToRecommendations})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All'; // 'All' or a group name

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          // ── Location + Refresh Bar ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF388E3C),
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: LocationInput(
                      initialLocation: state.location,
                      onLocationChanged: (val) {
                        state.updateProfile(state.name, val, state.language);
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    onPressed: () => setState(() {}),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
          ),

          // ── Section Title ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🌾  Crop Supply Alerts',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20)),
                  ),
                  GestureDetector(
                    onTap: widget.onNavigateToRecommendations,
                    child: const Text('Market Prices →',
                        style: TextStyle(
                            color: Color(0xFF388E3C),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          // ── Legend row ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Wrap(
                spacing: 14,
                children: [
                  _legendDot('🟢 Low Supply', const Color(0xFF388E3C)),
                  _legendDot('🟡 Moderate', const Color(0xFFF9A825)),
                  _legendDot('🔴 High Supply', const Color(0xFFD32F2F)),
                ],
              ),
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search crops...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF388E3C), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 17),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          })
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF388E3C), width: 1.5)),
                ),
              ),
            ),
          ),

          // ── Category filter chips ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  'All',
                  'Vegetables',
                  'Cereals',
                  'Pulses',
                  'Fruits',
                  'Commercial',
                  'Spices',
                  'Others'
                ].map((cat) {
                  final active = _activeFilter == cat;
                  final color = cat == 'All'
                      ? const Color(0xFF388E3C)
                      : (_groupColors[cat] ?? const Color(0xFF546E7A));
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeFilter = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? color : Colors.white,
                          border: Border.all(
                              color: active
                                  ? color
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cat != 'All') ...[
                              Icon(
                                _groupIcons[cat] ?? Icons.agriculture,
                                size: 13,
                                color: active ? Colors.white : color,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: active ? Colors.white : Colors.black87,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Grouped Crop Cards ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _GroupedCropCards(
              location: state.location,
              searchQuery: _searchQuery,
              activeFilter: _activeFilter,
            ),
          ),

          // ── Market Prices Button ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.trending_up),
                label: const Text('View Market Prices'),
                onPressed: widget.onNavigateToRecommendations,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 9,
          height: 9,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }
}

// ─── Crop Categorization ────────────────────────────────────────────────────
const Map<String, String> _cropGroup = {
  'tomato': 'Vegetables', 'onion': 'Vegetables', 'brinjal': 'Vegetables',
  'cabbage': 'Vegetables', 'carrot': 'Vegetables', 'beans': 'Vegetables',
  'drumstick': 'Vegetables', 'chilli': 'Vegetables', 'chili': 'Vegetables',
  'capsicum': 'Vegetables', 'coriander': 'Vegetables', 'potato': 'Vegetables',
  'beetroot': 'Vegetables', 'radish': 'Vegetables', 'gourd': 'Vegetables',
  'paddy': 'Cereals', 'rice': 'Cereals', 'maize': 'Cereals', 'corn': 'Cereals',
  'wheat': 'Cereals', 'millet': 'Cereals', 'sorghum': 'Cereals',
  'ragi': 'Cereals', 'barley': 'Cereals',
  'black gram': 'Pulses', 'green gram': 'Pulses', 'horse gram': 'Pulses',
  'groundnut': 'Pulses', 'red gram': 'Pulses', 'chickpea': 'Pulses',
  'soybean': 'Pulses', 'cowpea': 'Pulses', 'lentil': 'Pulses',
  'cotton': 'Commercial', 'sugarcane': 'Commercial', 'tobacco': 'Commercial',
  'jute': 'Commercial', 'castor': 'Commercial', 'sesame': 'Commercial',
  'sunflower': 'Commercial', 'mustard': 'Commercial',
  'banana': 'Fruits', 'mango': 'Fruits', 'watermelon': 'Fruits',
  'papaya': 'Fruits', 'guava': 'Fruits', 'pomegranate': 'Fruits',
  'grape': 'Fruits', 'coconut': 'Fruits', 'pineapple': 'Fruits',
  'jackfruit': 'Fruits',
  'turmeric': 'Spices', 'ginger': 'Spices', 'pepper': 'Spices',
  'cardamom': 'Spices', 'chillies': 'Spices', 'garlic': 'Spices',
  'cinnamon': 'Spices', 'clove': 'Spices',
};

String _getGroup(String cropName) {
  final lower = cropName.toLowerCase();
  for (final entry in _cropGroup.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  return 'Others';
}

const Map<String, IconData> _groupIcons = {
  'Vegetables': Icons.eco,
  'Cereals': Icons.grain,
  'Pulses': Icons.circle_outlined,
  'Commercial': Icons.factory_outlined,
  'Fruits': Icons.apple,
  'Spices': Icons.spa,
  'Others': Icons.agriculture,
};

const Map<String, Color> _groupColors = {
  'Vegetables': Color(0xFF43A047),
  'Cereals': Color(0xFF795548),
  'Pulses': Color(0xFF7B1FA2),
  'Commercial': Color(0xFF0277BD),
  'Fruits': Color(0xFFE65100),
  'Spices': Color(0xFFC62828),
  'Others': Color(0xFF546E7A),
};

// ─── Grouped Crop Cards Widget ───────────────────────────────────────────────
class _GroupedCropCards extends StatelessWidget {
  final String location;
  final String searchQuery;
  final String activeFilter;

  const _GroupedCropCards({
    required this.location,
    required this.searchQuery,
    required this.activeFilter,
  });

  Color _cardBg(DemandLevel l) {
    switch (l) {
      case DemandLevel.high: return const Color(0xFFFFEBEE);
      case DemandLevel.moderate: return const Color(0xFFFFFDE7);
      case DemandLevel.low: return const Color(0xFFE8F5E9);
    }
  }

  Color _accent(DemandLevel l) {
    switch (l) {
      case DemandLevel.high: return const Color(0xFFD32F2F);
      case DemandLevel.moderate: return const Color(0xFFF9A825);
      case DemandLevel.low: return const Color(0xFF388E3C);
    }
  }

  IconData _levelIcon(DemandLevel l) {
    switch (l) {
      case DemandLevel.high: return Icons.trending_down;
      case DemandLevel.moderate: return Icons.trending_flat;
      case DemandLevel.low: return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    var crops = MockApi().analyzeDemand(location);

    // ── Apply search filter ──────────────────────────────────────────────
    if (searchQuery.isNotEmpty) {
      crops = crops.where((c) =>
          c.cropName.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // ── Apply category filter ────────────────────────────────────────────
    if (activeFilter != 'All') {
      crops = crops.where((c) => _getGroup(c.cropName) == activeFilter).toList();
    }

    if (crops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(children: [
            const Icon(Icons.search_off, size: 44, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty
                  ? 'No crops matching "$searchQuery"'
                  : 'No crops found in "$activeFilter" category',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
    }

    // ── Group crops ──────────────────────────────────────────────────────
    final Map<String, List<CropDemandResult>> grouped = {};
    for (final c in crops) {
      final grp = _getGroup(c.cropName);
      grouped.putIfAbsent(grp, () => []).add(c);
    }

    const order = ['Vegetables', 'Cereals', 'Pulses', 'Fruits', 'Commercial', 'Spices', 'Others'];
    final sortedGroups = order.where(grouped.containsKey).toList()
      ..addAll(grouped.keys.where((k) => !order.contains(k)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sortedGroups.map((groupName) {
          final groupCrops = grouped[groupName]!;
          final groupColor = _groupColors[groupName] ?? const Color(0xFF546E7A);
          final groupIcon = _groupIcons[groupName] ?? Icons.agriculture;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Group header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: groupColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(groupIcon, color: groupColor, size: 15),
                  ),
                  const SizedBox(width: 7),
                  Text(groupName,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: groupColor)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: groupColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${groupCrops.length}',
                        style: TextStyle(
                            fontSize: 10,
                            color: groupColor,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                      child:
                          Divider(indent: 8, color: groupColor.withOpacity(0.2))),
                ]),
              ),

              // ── 5-per-row compact grid ────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.88,
                ),
                itemCount: groupCrops.length,
                itemBuilder: (ctx, i) {
                  final c = groupCrops[i];
                  final bg = _cardBg(c.level);
                  final ac = _accent(c.level);
                  return GestureDetector(
                    onTap: () => showCropHistoryPopup(ctx, c),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(11),
                        border:
                            Border.all(color: ac.withOpacity(0.35), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                              color: ac.withOpacity(0.07),
                              blurRadius: 4,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top: trend icon + count badge
                          Row(children: [
                            Icon(_levelIcon(c.level), color: ac, size: 13),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(
                                color: ac.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('×${c.count}',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: ac)),
                            ),
                          ]),
                          const SizedBox(height: 5),
                          // Crop name
                          Text(c.cropName,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          // Harvest month
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(c.harvestMonth,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 3),
                          // Alert message
                          Text(c.message,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: ac,
                                  fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
