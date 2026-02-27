import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/farmer_state.dart';
import 'services/mock_api.dart';
import 'screens/dashboard.dart';
import 'screens/recommendations.dart';
import 'screens/schemes.dart';
import 'screens/profile.dart';
import 'screens/auth.dart';

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
      title: 'AgriApp - Farmer Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF388E3C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F8E9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF388E3C),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB2DFDB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB2DFDB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: Consumer<FarmerState>(
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF388E3C)),
              ),
            );
          }
          // Not yet registered → show Auth (register or login)
          if (!state.isRegistered) {
            return const AuthScreen();
          }
          // Registered but not logged in → show Auth (login page)
          if (!state.isLoggedIn) {
            return const AuthScreen();
          }
          // Fully authenticated → show main app
          return const MainNavigator();
        },
      ),
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

  void _navigateToRecommendations() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);

    final List<Widget> screens = [
      DashboardScreen(onNavigateToRecommendations: _navigateToRecommendations),
      const RecommendationsScreen(),
      const SchemesScreen(),
      const ProfileScreen(),
    ];

    final List<String> titles = [
      'Market Dashboard',
      'Recommendations',
      'Govt. Schemes',
      'My Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset('assets/images/logo.png', width: 24, height: 24),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titles[_currentIndex],
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Welcome, ${state.name.isEmpty ? "Farmer" : state.name}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language switcher
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: state.language,
                dropdownColor: const Color(0xFF2E7D32),
                icon: const Icon(Icons.language, color: Colors.white, size: 18),
                isDense: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'ta', child: Text('தமிழ்', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    state.updateProfile(state.name, state.location, val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF388E3C),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.store_outlined),
              activeIcon: const Icon(Icons.store),
              label: state.get('dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up_outlined),
              activeIcon: const Icon(Icons.trending_up),
              label: state.get('recommendations'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.article_outlined),
              activeIcon: const Icon(Icons.article),
              label: state.get('schemes'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: state.get('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
