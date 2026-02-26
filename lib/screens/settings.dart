import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    final state = Provider.of<FarmerState>(context, listen: false);
    _nameController = TextEditingController(text: state.name);
    _locationController = TextEditingController(text: state.location);
    _language = state.language;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(state.get('settings')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: state.get('name')),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(labelText: state.get('location')),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: InputDecoration(labelText: state.get('language')),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _language = val);
              }
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              state.updateProfile(_nameController.text, _locationController.text, _language);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved successfully!')),
              );
            },
            child: Text(state.get('save'), style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              final exportedData = 'Profile: ${state.name}, ${state.location}';
              Clipboard.setData(ClipboardData(text: exportedData));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${state.get('export_data')} copied')),
              );
            },
            child: Text(state.get('export_data')),
          )
        ],
      ),
    );
  }
}
