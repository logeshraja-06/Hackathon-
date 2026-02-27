import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Gets the device's current GPS [Position].
/// Handles permission checks and throws descriptive exceptions.
Future<Position> getPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Location services are disabled.');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied.');
  }

  return await Geolocator.getCurrentPosition();
}

/// Reverse geocodes [lat]/[lng] using the free OpenStreetMap Nominatim API.
/// Works on ALL platforms including Flutter Web (no native SDK needed).
Future<String> reverseGeocode(double lat, double lng) async {
  try {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=en',
    );
    final response = await http.get(url, headers: {'User-Agent': 'AgriApp/1.0'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final addr = data['address'] as Map<String, dynamic>?;
      if (addr != null) {
        // Try city → town → village → county → state_district
        final city = addr['city'] ?? addr['town'] ?? addr['village'] ??
                     addr['county'] ?? addr['state_district'] ?? addr['state'] ?? '';
        return city.toString();
      }
    }
  } catch (_) {}
  return 'Unknown Location';
}
