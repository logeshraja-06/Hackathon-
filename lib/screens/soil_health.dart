import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../models/soil_report.dart';
import '../services/soil_ai_service.dart';
import '../widgets/visual_gauge.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SoilHealthScreen extends StatefulWidget {
  const SoilHealthScreen({Key? key}) : super(key: key);

  @override
  _SoilHealthScreenState createState() => _SoilHealthScreenState();
}

class _SoilHealthScreenState extends State<SoilHealthScreen> {
  bool _isProcessingOCR = false;
  SoilReport? _report;
  Map<String, dynamic>? _recommendation;
  String? _damAlert;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    final location = Provider.of<FarmerState>(context, listen: false).location;
    final alert = await SoilAiService().getDamReleaseAlert(location);
    if (mounted && alert != null) {
      setState(() => _damAlert = alert);
    }
  }

  Future<void> _handleUploadCard() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final String filePath = result.files.single.path!;
        
        setState(() {
          _selectedFile = File(filePath);
          _isProcessingOCR = true;
        });

        // Simulate OCR Extraction using the real file path
        final extractedReport = await SoilAiService().simulateOCR(imagePath: filePath);
        
        // Simulate AI Recommendation for default crop 'Samba Rice'
        final recs = SoilAiService().calculateFertilizer(extractedReport, 'Samba Rice');

        if (mounted) {
          setState(() {
            _report = extractedReport;
            _recommendation = recs;
            _isProcessingOCR = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingOCR = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.get('soil_health')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_damAlert != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_damAlert!, style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),

            if (_report == null) ...[
              const Icon(Icons.document_scanner, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                state.get('upload_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: _isProcessingOCR 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.camera_alt),
                label: Text(state.get('upload_card')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                onPressed: _isProcessingOCR ? null : _handleUploadCard,
              )
            ] else ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.get('extracted_params'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          VisualGauge(label: 'pH', value: _report!.phLevel, minVal: 0, maxVal: 14, optimalMin: 6.5, optimalMax: 7.5),
                          VisualGauge(label: 'EC', value: _report!.ecLevel, minVal: 0, maxVal: 4, optimalMin: 0.2, optimalMax: 1.5),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          VisualGauge(label: 'N (kg/ha)', value: _report!.nitrogen, minVal: 0, maxVal: 300, optimalMin: 140, optimalMax: 200),
                          VisualGauge(label: 'P (kg/ha)', value: _report!.phosphorus, minVal: 0, maxVal: 100, optimalMin: 20, optimalMax: 40),
                          VisualGauge(label: 'K (kg/ha)', value: _report!.potassium, minVal: 0, maxVal: 400, optimalMin: 150, optimalMax: 250),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(state.get('shopping_list'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const SizedBox(height: 8),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text('${state.get('urea')}: ${_recommendation!['urea_bags']} Bags (50kg)'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text('${state.get('dap')}: ${_recommendation!['dap_bags']} Bags (50kg)'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Colors.green),
                        title: Text('${state.get('mop')}: ${_recommendation!['mop_bags']} Bags (50kg)'),
                      ),
                      const Divider(),
                      Text('Note: PACCS Integration ready. Show this list at your local society.', style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              if (_report!.recommendedCrops != null && _report!.recommendedCrops!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(state.get('recommended_crops'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _report!.recommendedCrops!.map((crop) => Chip(
                    label: Text(crop),
                    avatar: const Icon(Icons.grass, color: Colors.green, size: 18),
                    backgroundColor: Colors.orange.shade50,
                    side: BorderSide(color: Colors.orange.shade200),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Another Card'),
                onPressed: () => setState(() {
                  _report = null;
                  _selectedFile = null;
                }),
              )
            ]
          ],
        ),
      ),
    );
  }
}
