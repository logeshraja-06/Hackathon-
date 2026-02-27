import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../utils/location_utils.dart';
import '../state/farmer_state.dart';

class LocationInput extends StatefulWidget {
  final String initialLocation;
  final Function(String) onLocationChanged;

  const LocationInput({
    Key? key,
    required this.initialLocation,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  late TextEditingController _controller;
  bool _isLocating = false;

  Future<void> _launchMap(FarmerState state) async {
    if (state.latitude != null && state.longitude != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${state.latitude},${state.longitude}';
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map.')));
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS coordinates not set. Please use the detect button.')));
    }
  }

  Future<void> _detectLocation(FarmerState state) async {
    setState(() => _isLocating = true);
    try {
      Position position = await getPosition();
      String locStr = await reverseGeocode(position.latitude, position.longitude);

      setState(() {
        _controller.text = locStr;
      });
      // Directly update state to ensure lat/lng are saved
      state.updateProfile(state.name, locStr, state.language,
          newLat: position.latitude, newLng: position.longitude);
      widget.onLocationChanged(locStr);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    
    return Row(
      children: [
        InkWell(
          onTap: () => _launchMap(state),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.location_on, color: Colors.blue, size: 28),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: state.get('location'),
              border: const UnderlineInputBorder(),
            ),
            onSubmitted: widget.onLocationChanged,
          ),
        ),
        _isLocating 
          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          : IconButton(
              icon: const Icon(Icons.my_location, color: Color(0xFFE65100)),
              onPressed: () => _detectLocation(state),
            )
      ],
    );
  }
}
