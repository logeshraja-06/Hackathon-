import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/crop_history.dart';
import '../models/crop_demand.dart';
import '../services/mock_api.dart';

/// Call this to open the crop history bottom sheet popup.
void showCropHistoryPopup(BuildContext context, CropDemandResult crop) {
  final history = MockApi().getCropHistory(crop.cropName);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CropHistorySheet(crop: crop, history: history),
  );
}

class _CropHistorySheet extends StatefulWidget {
  final CropDemandResult crop;
  final CropHistory? history;
  const _CropHistorySheet({required this.crop, required this.history});

  @override
  State<_CropHistorySheet> createState() => _CropHistorySheetState();
}

class _CropHistorySheetState extends State<_CropHistorySheet> {
  int _touchedIndex = -1;

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  static const _yearColors = [Color(0xFF388E3C), Color(0xFF1976D2), Color(0xFFE65100)];

  Color _demandColor(DemandLevel l) {
    switch (l) {
      case DemandLevel.high: return const Color(0xFFD32F2F);
      case DemandLevel.moderate: return const Color(0xFFF9A825);
      case DemandLevel.low: return const Color(0xFF388E3C);
    }
  }

  String _demandLabel(DemandLevel l) {
    switch (l) {
      case DemandLevel.high: return '🔴 HIGH SUPPLY';
      case DemandLevel.moderate: return '🟡 MODERATE';
      case DemandLevel.low: return '🟢 LOW SUPPLY';
    }
  }

  List<LineChartBarData> _buildLines(CropHistory h) {
    return h.years.asMap().entries.map((entry) {
      final i = entry.key;
      final y = entry.value;
      return LineChartBarData(
        spots: y.monthlyPrices.asMap().entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
        isCurved: true,
        color: _yearColors[i % _yearColors.length],
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: _yearColors[i % _yearColors.length].withOpacity(0.07),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.crop;
    final h = widget.history;
    final accent = _demandColor(c.level);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF1F8E9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),

            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F8E9),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.cropName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 2),
                          Text(c.region, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_demandLabel(c.level),
                                style: TextStyle(fontSize: 11, color: accent, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  // Current season info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statChip('Farmers', '${c.count}', Icons.people_outline, const Color(0xFF388E3C)),
                          _statChip('Total Area', '${c.totalArea.toStringAsFixed(1)} ac', Icons.landscape_outlined, const Color(0xFF1976D2)),
                          _statChip('Harvest', c.harvestMonth, Icons.calendar_month_outlined, accent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Alert message banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(c.message,
                            style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (h == null) ...[
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No historical price data available for this crop.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    )),
                  ] else ...[
                    // Chart title + legend
                    Row(
                      children: [
                        const Text('Price History (3 Years)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B5E20))),
                        const Spacer(),
                        ...h.years.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(children: [
                            Container(width: 12, height: 3, color: _yearColors[e.key % _yearColors.length]),
                            const SizedBox(width: 4),
                            Text('${e.value.year}', style: const TextStyle(fontSize: 11)),
                          ]),
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ─── LINE CHART ──────────────────────────────────────
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (v) =>
                                FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                            getDrawingVerticalLine: (v) =>
                                FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 48,
                                getTitlesWidget: (v, _) => Text(
                                  '₹${(v / 1000).toStringAsFixed(1)}k',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= _months.length) return const SizedBox();
                                  return Text(_months[idx], style: const TextStyle(fontSize: 9, color: Colors.grey));
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (spots) => spots.map((s) {
                                final yr = h.years[s.barIndex].year;
                                return LineTooltipItem(
                                  '${_months[s.x.toInt()]} $yr\n₹${s.y.toInt()}',
                                  TextStyle(color: _yearColors[s.barIndex % _yearColors.length], fontSize: 11, fontWeight: FontWeight.bold),
                                );
                              }).toList(),
                            ),
                          ),
                          lineBarsData: _buildLines(h),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Unit: ${h.unit}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 20),

                    // ─── YEAR CARDS ──────────────────────────────────────
                    const Text('Year-by-Year Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B5E20))),
                    const SizedBox(height: 10),
                    ...h.years.asMap().entries.map((entry) {
                      final i = entry.key;
                      final y = entry.value;
                      final col = _yearColors[i % _yearColors.length];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(width: 4, height: 20, color: col, margin: const EdgeInsets.only(right: 10)),
                                Text('${y.year}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: col)),
                                const Spacer(),
                                Text('Production: ${y.totalProductionTons.toInt()} T',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ]),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _yearStat('Avg Price', '₹${y.avgPrice.toInt()}', col),
                                  _yearStat('Peak Price', '₹${y.peakPrice.toInt()}', const Color(0xFFD32F2F)),
                                  _yearStat('Low Price', '₹${y.lowPrice.toInt()}', const Color(0xFF388E3C)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _yearStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
