import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerState extends ChangeNotifier {
  String name = 'Farmer';
  String location = 'Chennai';
  String language = 'en';

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
    name = prefs.getString('farmer_name') ?? 'Farmer';
    location = prefs.getString('farmer_location') ?? 'Chennai';
    language = prefs.getString('farmer_language') ?? 'en';
    notifyListeners();
  }

  Future<void> updateProfile(String newName, String newLocation, String newLanguage) async {
    name = newName;
    location = newLocation;
    language = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', name);
    await prefs.setString('farmer_location', location);
    await prefs.setString('farmer_language', language);
    notifyListeners();
  }
}
