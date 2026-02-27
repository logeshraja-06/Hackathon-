import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../models/crop_recommendation.dart';
import '../models/crop_profit.dart';
import '../models/land_record.dart';
import '../services/crop_advisor_service.dart';
import '../services/profit_calculator_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main container — tabs between Crop Advisor and Profitability Calculator
// ─────────────────────────────────────────────────────────────────────────────
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);
  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0 = Advisor, 1 = Calculator

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Column(
        children: [
          // ── Gradient header with tab switcher ──────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌾 Farm Intelligence',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Crop recommendations & profit projections',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 16),
                // Tab row
                Row(
                  children: [
                    _tabButton(0, '🌱 Crop Advisor'),
                    const SizedBox(width: 8),
                    _tabButton(1, '💰 Profit Calculator'),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab content ─────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _tab == 0
                  ? const _CropAdvisorPage(key: ValueKey('advisor'))
                  : const _ProfitCalculatorPage(key: ValueKey('calc')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(int idx, String label) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: active ? const Color(0xFF1B5E20) : Colors.white,
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 0 — Crop Advisor
// ─────────────────────────────────────────────────────────────────────────────
class _CropAdvisorPage extends StatefulWidget {
  const _CropAdvisorPage({Key? key}) : super(key: key);
  @override
  State<_CropAdvisorPage> createState() => _CropAdvisorPageState();
}

class _CropAdvisorPageState extends State<_CropAdvisorPage> {
  SoilType? _soil;
  WaterAvailability? _water;
  late TextEditingController _locCtrl;
  List<CropRecommendation> _results = [];
  bool _searched = false, _loading = false;

  @override
  void initState() {
    super.initState();
    _locCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = Provider.of<FarmerState>(context, listen: false).location;
      _locCtrl.text = loc;
    });
  }

  @override
  void dispose() { _locCtrl.dispose(); super.dispose(); }

  Future<void> _search() async {
    if (_soil == null || _water == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select Soil Type and Water Availability'),
        backgroundColor: Colors.orange));
      return;
    }
    setState(() { _loading = true; });
    await Future.delayed(const Duration(milliseconds: 600));
    final r = CropAdvisorService().recommend(
        soil: _soil!, water: _water!, region: _locCtrl.text);
    setState(() { _results = r; _searched = true; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Form Card
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Location
              const Text('📍 Region', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _locCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Madurai, Coimbatore...',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF388E3C)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Soil type
              const Text('🟤 Soil Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: SoilType.values.map((s) {
                  final sel = _soil == s;
                  return GestureDetector(
                    onTap: () => setState(() => _soil = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF388E3C) : Colors.white,
                        border: Border.all(color: sel ? const Color(0xFF388E3C) : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s.label, style: TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Colors.black87)),
                    ),
                  );
                }).toList(),
              ),
              if (_soil != null) ...[
                const SizedBox(height: 4),
                Text('ℹ️ ${_soil!.description}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
              const SizedBox(height: 16),

              // Water
              const Text('💧 Water Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(children: WaterAvailability.values.map((w) {
                final sel = _water == w;
                final cols = {
                  WaterAvailability.high: const Color(0xFF1565C0),
                  WaterAvailability.medium: const Color(0xFF0288D1),
                  WaterAvailability.low: const Color(0xFF388E3C),
                };
                final c = cols[w]!;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _water = w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? c : Colors.white,
                      border: Border.all(color: sel ? c : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(children: [
                      Text(w == WaterAvailability.high ? '💧💧💧' : w == WaterAvailability.medium ? '💧💧' : '💧',
                          style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(w.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                          color: sel ? Colors.white : Colors.black87)),
                    ]),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 18),

              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: _loading
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                  label: Text(_loading ? 'Analyzing...' : 'Get Recommendations',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  onPressed: _loading ? null : _search,
                )),
            ]),
          ),
        ),

        // Results
        if (_searched && _results.isEmpty) ...[
          const SizedBox(height: 32),
          const Center(child: Column(children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No matching crops found. Try different inputs.',
                style: TextStyle(color: Colors.grey)),
          ])),
        ],
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(children: [
            const Text('✅ Recommended Crops',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Text('${_results.length} crops',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          ..._results.map((r) => _AdvisorCard(rec: r)),
        ],
      ],
    );
  }
}

class _AdvisorCard extends StatelessWidget {
  final CropRecommendation rec;
  const _AdvisorCard({required this.rec});

  Color get _trendColor => rec.priceTrend == 'Rising'
      ? const Color(0xFF2E7D32) : rec.priceTrend == 'Falling'
      ? const Color(0xFFD32F2F) : const Color(0xFFF9A825);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(rec.emoji, style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rec.cropName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${rec.soilMatch}  •  ${rec.waterNeed} water',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
              child: Text('${rec.confidenceScore}% match',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF388E3C)))),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rec.confidenceScore / 100, minHeight: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF388E3C)))),
          const SizedBox(height: 10),
          Row(children: [
            _chip(Icons.calendar_today_outlined, rec.durationLabel, Colors.blueGrey),
            const SizedBox(width: 8),
            _chip(Icons.wb_sunny_outlined, rec.bestSowingMonths, Colors.orange),
            const SizedBox(width: 8),
            _chip(Icons.trending_up, rec.priceTrend, _trendColor),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _trendColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _trendColor.withOpacity(0.25))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.currency_rupee, size: 14, color: _trendColor),
              Text('Expected: ${rec.priceRange}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _trendColor, fontSize: 12)),
            ])),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFFF9A825)),
            const SizedBox(width: 6),
            Expanded(child: Text(rec.reason,
                style: const TextStyle(fontSize: 11, color: Colors.black54, height: 1.4))),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Profitability Calculator
// ─────────────────────────────────────────────────────────────────────────────
class _ProfitCalculatorPage extends StatefulWidget {
  const _ProfitCalculatorPage({Key? key}) : super(key: key);
  @override
  State<_ProfitCalculatorPage> createState() => _ProfitCalculatorPageState();
}

class _ProfitCalculatorPageState extends State<_ProfitCalculatorPage> {
  String? _selectedCrop;
  LandRecord? _selectedLand;  // ← from profile
  ProfitReport? _report;
  String? _error;

  final _crops = ProfitCalculatorService().allCropNames;

  @override
  void dispose() { super.dispose(); }

  void _calculate() {
    if (_selectedCrop == null) {
      setState(() => _error = 'Please select a crop');
      return;
    }
    if (_selectedLand == null) {
      setState(() => _error = 'Please select a land from your profile');
      return;
    }
    try {
      final r = ProfitCalculatorService().calculate(
          cropName: _selectedCrop!, landAreaAcres: _selectedLand!.sizeAcres);
      setState(() { _report = r; _error = null; });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    final lands = state.lands;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Input Card ─────────────────────────────────────────────────
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🌾 Select Crop',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                hint: const Text('Choose a crop...'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
                  prefixIcon: Text(_selectedCrop != null
                    ? (ProfitCalculatorService().getCostData(_selectedCrop!)?.emoji ?? '🌱')
                    : '🌱', style: const TextStyle(fontSize: 18)),
                ),
                items: _crops.map((c) {
                  final d = ProfitCalculatorService().getCostData(c);
                  return DropdownMenuItem(value: c,
                    child: Text('${d?.emoji ?? ''} $c', style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: (v) => setState(() { _selectedCrop = v; _report = null; }),
              ),
              const SizedBox(height: 16),

              // ── Land dropdown from profile ──────────────────────────
              const Text('🗺️ Select Land',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              if (lands.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    border: Border.all(color: const Color(0xFFFFCA28)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Color(0xFFF9A825), size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'No land records found. Go to Profile → Add Land to add your fields.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    )),
                  ]),
                )
              else
                DropdownButtonFormField<LandRecord>(
                  value: _selectedLand,
                  hint: const Text('Choose your field...'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
                    prefixIcon: const Icon(Icons.landscape_outlined,
                        color: Color(0xFF388E3C), size: 20),
                  ),
                  items: lands.map((land) => DropdownMenuItem(
                    value: land,
                    child: Text(
                      '${land.name}  •  ${land.sizeAcres} acres  •  ${land.soilType.split(' ').first}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() { _selectedLand = v; _report = null; }),
                ),
              // Show details of selected land
              if (_selectedLand != null) ...[  
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF388E3C), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      '${_selectedLand!.sizeAcres} acres  •  ${_selectedLand!.location}  •  ${_selectedLand!.soilType}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                    ),
                  ]),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 16),

              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calculate Profit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  onPressed: _calculate,
                )),
            ]),
          ),
        ),

        // ── Report ───────────────────────────────────────────────────────
        if (_report != null) ...[
          const SizedBox(height: 16),
          _ProfitReportView(report: _report!),
        ],
      ],
    );
  }
}

// ─── Profit Report Widget ──────────────────────────────────────────────────────
class _ProfitReportView extends StatelessWidget {
  final ProfitReport r;
  const _ProfitReportView({required ProfitReport report}) : r = report;

  Color get _assessColor {
    switch (r.assessment) {
      case 'Excellent': return const Color(0xFF2E7D32);
      case 'Good': return const Color(0xFF388E3C);
      case 'Moderate': return const Color(0xFFF9A825);
      default: return const Color(0xFFD32F2F);
    }
  }

  String get _assessEmoji {
    switch (r.assessment) {
      case 'Excellent': return '🚀';
      case 'Good': return '✅';
      case 'Moderate': return '⚠️';
      default: return '❌';
    }
  }

  String _fmt(double v) => '₹${v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    // Pie chart sections
    final pieData = [
      PieChartSectionData(value: r.seedCost, color: const Color(0xFF81C784), title: 'Seed', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: r.fertilizerCost, color: const Color(0xFF4FC3F7), title: 'Fert.', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: r.pesticideCost, color: const Color(0xFFFFB74D), title: 'Pest.', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: r.laborCost, color: const Color(0xFFE57373), title: 'Labor', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: r.irrigationCost, color: const Color(0xFF9575CD), title: 'Irrig.', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
      PieChartSectionData(value: r.otherCost, color: const Color(0xFF90A4AE), title: 'Other', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Assessment Banner ──────────────────────────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _assessColor.withOpacity(0.1),
          border: Border.all(color: _assessColor.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Text(_assessEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${r.emoji} ${r.cropName} — ${r.assessment} Returns',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _assessColor)),
            Text('${r.landAreaAcres.toStringAsFixed(2)} acres  •  ROI: ${r.roiPct.toStringAsFixed(1)}%  •  Margin: ${r.profitMarginPct.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ]),
      ),
      const SizedBox(height: 12),

      // ── Summary cards row ──────────────────────────────────────────────
      Row(children: [
        _summaryCard('Total Cost', _fmt(r.totalCost), const Color(0xFFD32F2F), Icons.money_off),
        const SizedBox(width: 8),
        _summaryCard('Gross Income', _fmt(r.grossIncome), const Color(0xFF1565C0), Icons.attach_money),
        const SizedBox(width: 8),
        _summaryCard('Net Profit', _fmt(r.netProfit), _assessColor, Icons.account_balance_wallet_outlined),
      ]),
      const SizedBox(height: 12),

      // ── Cost Breakdown Pie Chart ──────────────────────────────────────
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cost Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20))),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Row(children: [
                Expanded(flex: 2, child: PieChart(PieChartData(
                  sections: pieData,
                  centerSpaceRadius: 35,
                  sectionsSpace: 2,
                ))),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legend('🟢 Seeds', _fmt(r.seedCost)),
                    _legend('🔵 Fertilizers', _fmt(r.fertilizerCost)),
                    _legend('🟠 Pesticides', _fmt(r.pesticideCost)),
                    _legend('🔴 Labor', _fmt(r.laborCost)),
                    _legend('🟣 Irrigation', _fmt(r.irrigationCost)),
                    _legend('⚪ Others', _fmt(r.otherCost)),
                  ],
                )),
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),

      // ── Yield & Income Detail Card ────────────────────────────────────
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Yield & Income Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20))),
            const SizedBox(height: 10),
            _detailRow('Expected Yield', '${r.expectedYieldQuintals.toStringAsFixed(1)} quintals'),
            _detailRow('Market Price', '${_fmt(r.marketPricePerQuintal)} / quintal'),
            _detailRow('Gross Income', _fmt(r.grossIncome)),
            const Divider(),
            _detailRow('Total Cost', _fmt(r.totalCost)),
            _detailRow('Net Profit', _fmt(r.netProfit),
                bold: true, color: r.netProfit >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F)),
            _detailRow('Return on Investment', '${r.roiPct.toStringAsFixed(1)}%'),
          ]),
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    ));
  }

  Widget _legend(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _detailRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(value, style: TextStyle(fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: color ?? Colors.black87)),
      ]),
    );
  }
}
