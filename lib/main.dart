import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/farmer_state.dart';
import 'services/mock_api.dart';
import 'screens/dashboard.dart';
import 'screens/recommendations.dart';
import 'screens/buyers.dart';
import 'screens/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockApi().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => FarmerState(),
      child: const SmartCropApp(),
    ),
  );
}

class SmartCropApp extends StatelessWidget {
  const SmartCropApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Crop Demand Planner',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFE65100),
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  String? _selectedCropForBuyers;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index != 2) _selectedCropForBuyers = null;
    });
  }

  void _navigateToRecommendations() {
    setState(() => _currentIndex = 1);
  }

  void _navigateToBuyersWithCrop(String cropId) {
    setState(() {
      _selectedCropForBuyers = cropId;
      _currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    
    final List<Widget> _screens = [
      DashboardScreen(onNavigateToRecommendations: _navigateToRecommendations),
      RecommendationsScreen(onSeeBuyers: _navigateToBuyersWithCrop),
      BuyersScreen(initialCropFilter: _selectedCropForBuyers),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE65100),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: state.get('dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.thumb_up), label: state.get('recommendations')),
          BottomNavigationBarItem(icon: const Icon(Icons.people), label: state.get('buyers')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: state.get('settings')),
        ],
      ),
    );
  }
}
