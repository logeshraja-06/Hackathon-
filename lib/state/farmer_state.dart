import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land_record.dart';

class FarmerState extends ChangeNotifier {
  String name = '';
  String location = '';
  String username = '';
  String password = '';
  double? latitude;
  double? longitude;
  String language = 'en';
  bool isRegistered = false;
  bool isLoggedIn = false;  // set only after explicit login
  bool isLoading = true;
  List<LandRecord> lands = [];

  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'dashboard': 'Dashboard',
      'recommendations': 'Recommendations',
      'buyers': 'Buyers',
      'settings': 'Settings',
      'high_demand': 'High Demand Crops',
      'get_recommendations': 'Get Recommendations',
      'see_buyers': 'See Buyers',
      'contact_copied': 'Contact copied to clipboard!',
      'no_buyers': 'No buyers found in your area.',
      'name': 'Farmer Name',
      'location': 'Location',
      'language': 'Language',
      'export_data': 'Export Data',
      'save': 'Save Profile',
      'soil_health': 'Soil Health',
      'upload_card': 'Upload Soil Card',
      'upload_desc': 'Scan your TN Government Soil Health Card to get AI-driven precision fertilizer recommendations.',
      'extracted_params': 'Extracted Soil Parameters',
      'shopping_list': 'Fertilizer Shopping List',
      'urea': 'Urea',
      'dap': 'DAP',
      'mop': 'MOP',
      'recommended_crops': 'Recommended Crops',
      'login': 'Farmer Login',
      'register': 'Register as Farmer',
      'detect_location': 'Detect My Location',
      'continue': 'Continue',
      'profile': 'Profile',
      'schemes': 'Govt Schemes',
    },
    'ta': {
      'dashboard': 'முகப்பு',
      'recommendations': 'பரிந்துரைகள்',
      'buyers': 'வாங்குபவர்கள்',
      'settings': 'அமைப்புகள்',
      'high_demand': 'அதிக தேவை உள்ள பயிர்கள்',
      'get_recommendations': 'பரிந்துரைகளைப் பெறுக',
      'see_buyers': 'வாங்குபவர்களைப் பார்க்க',
      'contact_copied': 'தொடர்பு நகலெடுக்கப்பட்டது!',
      'no_buyers': 'உங்கள் பகுதியில் வாங்குபவர்கள் இல்லை.',
      'name': 'விவசாயி பெயர்',
      'location': 'இடம்',
      'language': 'மொழி',
      'export_data': 'தரவு ஏற்றுமதி',
      'save': 'சேமி',
      'soil_health': 'மண் வளம்',
      'upload_card': 'அட்டை பதிவேற்றுக',
      'upload_desc': 'துல்லியமான உர பரிந்துரைகளுக்கு உங்கள் மண் வள அட்டையை ஸ்கேன் செய்யவும்.',
      'extracted_params': 'பிரித்தெடுக்கப்பட்ட மண் அளவீடுகள்',
      'shopping_list': 'உர கொள்முதல் பட்டியல்',
      'urea': 'யூரியா',
      'dap': 'டி.ஏ.பி (DAP)',
      'mop': 'எம்.ஓ.பி (MOP)',
      'recommended_crops': 'பரிந்துரைக்கப்படும் பயிர்கள்',
      'login': 'விவசாயி உள்நுழைவு',
      'register': 'விவசாயியாக பதிவு செய்யவும்',
      'detect_location': 'எனது இடத்தை கண்டறி',
      'continue': 'தொடரவும்',
      'profile': 'சுயவிவரம்',
      'schemes': 'அரசு திட்டங்கள்',
    }
  };

  FarmerState() {
    _loadProfile();
  }

  String get(String key) {
    return _localizedStrings[language]?[key] ?? key;
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('farmer_name') ?? '';
    location = prefs.getString('farmer_location') ?? '';
    username = prefs.getString('farmer_username') ?? '';
    password = prefs.getString('farmer_password') ?? '';
    if (prefs.containsKey('farmer_lat')) {
      latitude = prefs.getDouble('farmer_lat');
    }
    if (prefs.containsKey('farmer_lng')) {
      longitude = prefs.getDouble('farmer_lng');
    }
    language = prefs.getString('farmer_language') ?? 'en';
    isRegistered = prefs.getBool('farmer_registered') ?? false;
    isLoading = false;
    notifyListeners();
  }

  Future<void> register(String newName, String newLocation, String newUsername, String newPassword, {double? newLat, double? newLng}) async {
    name = newName;
    location = newLocation;
    username = newUsername;
    password = newPassword;
    latitude = newLat;
    longitude = newLng;
    isRegistered = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', name);
    await prefs.setString('farmer_location', location);
    await prefs.setString('farmer_username', username);
    await prefs.setString('farmer_password', password);
    if (latitude != null) await prefs.setDouble('farmer_lat', latitude!);
    if (longitude != null) await prefs.setDouble('farmer_lng', longitude!);
    await prefs.setBool('farmer_registered', true);
    notifyListeners();
  }

  // ── Land record helpers ──────────────────────────────────────────────────
  void addLand(LandRecord record) {
    lands.add(record);
    notifyListeners();
  }

  void updateLand(int index, LandRecord record) {
    lands[index] = record;
    notifyListeners();
  }

  void removeLand(int index) {
    lands.removeAt(index);
    notifyListeners();
  }

  bool login(String inputUsername, String inputPassword) {
    if (username.isNotEmpty && password.isNotEmpty &&
        username == inputUsername && password == inputPassword) {
      isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    isLoggedIn = false;
    isRegistered = false;
    name = '';
    location = '';
    latitude = null;
    longitude = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('farmer_registered');
    await prefs.remove('farmer_lat');
    await prefs.remove('farmer_lng');
    notifyListeners();
  }

  Future<void> updateProfile(String newName, String newLocation, String newLanguage, {double? newLat, double? newLng}) async {
    name = newName;
    location = newLocation;
    language = newLanguage;
    if (newLat != null) latitude = newLat;
    if (newLng != null) longitude = newLng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', name);
    await prefs.setString('farmer_location', location);
    await prefs.setString('farmer_language', language);
    if (latitude != null) await prefs.setDouble('farmer_lat', latitude!);
    if (longitude != null) await prefs.setDouble('farmer_lng', longitude!);
    notifyListeners();
  }
}
