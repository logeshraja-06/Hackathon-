import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/location_utils.dart';
import '../state/farmer_state.dart';

/// Entry point that decides to show Login or Register page.
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? _LoginPage(onGoToRegister: () => setState(() => _showLogin = false))
        : _RegisterPage(onGoToLogin: () => setState(() => _showLogin = true));
  }
}

// ─────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────
class _LoginPage extends StatefulWidget {
  final VoidCallback onGoToRegister;
  const _LoginPage({required this.onGoToRegister});

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  void _login() {
    final state = Provider.of<FarmerState>(context, listen: false);
    final ok = state.login(_usernameCtrl.text.trim(), _passwordCtrl.text.trim());
    if (!ok) {
      setState(() => _error = 'Invalid username or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 100, height: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              const Text('AgriApp', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const Text('Farmer Marketplace', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 36),

              // Card
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.get('login'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      const SizedBox(height: 20),

                      // Username
                      TextField(
                        controller: _usernameCtrl,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (_) => setState(() => _error = null),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _login(),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ],

                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _login,
                        child: const Text('Login', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 12),

                      // Go to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: widget.onGoToRegister,
                            child: const Text('Register', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REGISTRATION PAGE
// ─────────────────────────────────────────────
class _RegisterPage extends StatefulWidget {
  final VoidCallback onGoToLogin;
  const _RegisterPage({required this.onGoToLogin});

  @override
  State<_RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<_RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLocating = false;
  double? _lat;
  double? _lng;

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      Position position = await getPosition();
      String locStr = await reverseGeocode(position.latitude, position.longitude);
      setState(() {
        _locationCtrl.text = locStr;
        _lat = position.latitude;
        _lng = position.longitude;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not detect location: $e')));
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (name.isEmpty || location.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }
    if (username.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username must be at least 4 characters.')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.')));
      return;
    }

    final state = Provider.of<FarmerState>(context, listen: false);
    await state.register(name, location, username, password, newLat: _lat, newLng: _lng);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Account created! Please log in.'),
          ]),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 3),
        ),
      );
      // Redirect to login page
      widget.onGoToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onGoToLogin,
        ),
        title: const Text('Create Account', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 70, height: 70,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, spreadRadius: 1)
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Register as Farmer', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                const SizedBox(height: 24),

                // Full Name
                _buildField(_nameCtrl, 'Full Name', Icons.badge_outlined),
                const SizedBox(height: 14),

                // Location
                TextField(
                  controller: _locationCtrl,
                  decoration: InputDecoration(
                    labelText: 'Location / District',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    hintText: 'e.g., Madurai, Tamil Nadu',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: _isLocating
                        ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                        : IconButton(
                            icon: const Icon(Icons.my_location, color: Colors.blue),
                            tooltip: 'Detect my location',
                            onPressed: _detectLocation,
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // Username
                _buildField(_usernameCtrl, 'Username', Icons.alternate_email),
                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Confirm Password
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _register,
                  child: const Text('Create Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: widget.onGoToLogin,
                      child: const Text('Login', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
