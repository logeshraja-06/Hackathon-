import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        const Icon(Icons.location_on, color: Color(0xFFE65100)),
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
        IconButton(
          icon: const Icon(Icons.my_location),
          onPressed: () {
            // Mock detect
            _controller.text = 'Coimbatore';
            widget.onLocationChanged('Coimbatore');
          },
        )
      ],
    );
  }
}
