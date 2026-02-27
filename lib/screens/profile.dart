import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../models/land_record.dart';

const _soilOptions = [
  'Red Soil',
  'Black Soil (Regur)',
  'Sandy Soil',
  'Clay / Alluvial Soil',
  'Loamy Soil',
  'Laterite Soil',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<FarmerState>(context, listen: false);
    _nameCtrl = TextEditingController(text: state.name);
    _locationCtrl = TextEditingController(text: state.location);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLandDialog({LandRecord? existing, int? index}) async {
    final state = Provider.of<FarmerState>(context, listen: false);
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final sizeCtrl = TextEditingController(
        text: existing != null ? existing.sizeAcres.toString() : '');
    final locCtrl = TextEditingController(text: existing?.location ?? '');
    String soil = existing?.soilType ?? _soilOptions.first;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setDlg) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: const Color(0xFF388E3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.landscape, color: Color(0xFF388E3C), size: 20),
            ),
            const SizedBox(width: 10),
            Text(existing == null ? 'Add Land Record' : 'Edit Land Record',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dialogField(nameCtrl, 'Field / Plot Name', Icons.edit_location_alt_outlined),
              const SizedBox(height: 12),
              _dialogField(sizeCtrl, 'Size (acres)', Icons.straighten_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 12),
              _dialogField(locCtrl, 'Location (Village / District)', Icons.location_on_outlined),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: soil,
                decoration: InputDecoration(
                  labelText: 'Soil Type',
                  prefixIcon: const Icon(Icons.layers_outlined, color: Color(0xFF388E3C), size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
                ),
                items: _soilOptions.map((s) =>
                    DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setDlg(() => soil = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                final nm = nameCtrl.text.trim();
                final sz = double.tryParse(sizeCtrl.text.trim()) ?? 0;
                final lc = locCtrl.text.trim();
                if (nm.isEmpty || sz <= 0 || lc.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Please fill all fields correctly.'),
                      backgroundColor: Colors.orange));
                  return;
                }
                final record = LandRecord(name: nm, sizeAcres: sz, location: lc, soilType: soil);
                if (existing == null) {
                  state.addLand(record);
                } else {
                  state.updateLand(index!, record);
                }
                Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        );
      }),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF388E3C), size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
      ),
    );
  }

  Color _soilColor(String soil) {
    if (soil.contains('Black')) return const Color(0xFF37474F);
    if (soil.contains('Red')) return const Color(0xFFC62828);
    if (soil.contains('Sandy')) return const Color(0xFFF9A825);
    if (soil.contains('Clay') || soil.contains('Alluvial')) return const Color(0xFF1565C0);
    if (soil.contains('Loamy')) return const Color(0xFF2E7D32);
    if (soil.contains('Laterite')) return const Color(0xFFBF360C);
    return Colors.grey;
  }

  void _confirmDelete(FarmerState state, int idx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Land Record?'),
        content: Text('Remove "${state.lands[idx].name}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              state.removeLand(idx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    final totalAcres = state.lands.fold(0.0, (s, l) => s + l.sizeAcres);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      state.name.isNotEmpty ? state.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(state.name.isNotEmpty ? state.name : 'Farmer',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(state.location.isNotEmpty ? state.location : 'Location not set',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  ]),
                ]),
                if (state.lands.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    _headerStat('${state.lands.length}', 'Plots'),
                    const SizedBox(width: 20),
                    _headerStat(totalAcres.toStringAsFixed(1), 'Total Acres'),
                  ]),
                ],
              ]),
            ),
          ),

          // ── Profile form ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('👤 Farmer Profile',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF388E3C), size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Location / Village',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF388E3C), size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF388E3C), width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Save Profile'),
                        onPressed: () {
                          state.updateProfile(_nameCtrl.text, _locationCtrl.text, state.language);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile saved!')));
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                        label: const Text('Logout', style: TextStyle(color: Colors.red)),
                        onPressed: () => state.logout(),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),

          // ── Land Records header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🗺️  My Land Records',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Land'),
                    onPressed: _openLandDialog,
                  ),
                ],
              ),
            ),
          ),

          // ── Empty state ──────────────────────────────────────────────────
          if (state.lands.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(children: [
                    Icon(Icons.landscape_outlined, size: 52, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('No land records yet.',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Tap "Add Land" to record your fields.',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ]),
                ),
              ),
            ),

          // ── Land record cards ────────────────────────────────────────────
          if (state.lands.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final land = state.lands[i];
                    final soilColor = _soilColor(land.soilType);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openLandDialog(existing: land, index: i),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Container(
                              width: 6, height: 72,
                              decoration: BoxDecoration(
                                color: soilColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(land.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _confirmDelete(state, i),
                                  ),
                                ]),
                                const SizedBox(height: 6),
                                Row(children: [
                                  _infoChip(Icons.straighten_outlined, '${land.sizeAcres} acres', Colors.blueGrey),
                                  const SizedBox(width: 8),
                                  _infoChip(Icons.location_on_outlined, land.location, Colors.teal),
                                ]),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: soilColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: soilColor.withOpacity(0.3)),
                                  ),
                                  child: Text(land.soilType,
                                      style: TextStyle(fontSize: 11, color: soilColor, fontWeight: FontWeight.w600)),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                    );
                  },
                  childCount: state.lands.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerStat(String value, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
    ]);
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 11, color: color)),
    ]);
  }
}
