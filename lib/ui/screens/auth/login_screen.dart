import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/map_provider.dart';

/**
 * 🔑 THE LOGIN SCREEN:
 * This widget handles the user interface for signing in.
 * It ensures that data is valid before sending it to the backend.
 */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 📋 THE FORM KEY: Tracks the state of the text fields for validation.
  final _formKey = GlobalKey<FormState>();

  // ✍️ TEXT CONTROLLERS: These "listen" to what the user types.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 👁️ UI STATE: Toggles whether the password is dots or readable text.
  bool _isPasswordVisible = false;

  /**
   * 🚀 THE LOGIN LOGIC:
   * This function orchestrates the flow from clicking "Sign In" to moving to the Map.
   */
  Future<void> _handleLogin() async {
    // 1. Check if the email looks like an email and the password isn't empty.
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = context.read<AuthProvider>();

      // 2. Call the AuthProvider to talk to the Spring Boot server.
      // This also fetches the user's current GPS location.
      final LatLng? location = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim()
      );

      // 3. If login is successful (we got a location back):
      if (location != null && mounted) {
        final mapProvider = context.read<MapProvider>();

        // 🧹 PREPARE THE MAP: Wipe old data and center the map on the user's current spot.
        mapProvider.resetMap();
        mapProvider.updateCenter(location);

        // ⭐ LOAD FAVORITES: Fetch this specific passenger's saved bus lines.
        if (authProvider.currentUser != null) {
          await mapProvider.loadFavorites(authProvider.currentUser!.id);
        }

        // 🗺️ NAVIGATION: Move to the MapScreen and delete the LoginScreen from history.
        Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
      }
    } catch (e) {
      // ❌ ERROR HANDLING: Show a red snackbar if credentials are wrong or server is down.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Login failed. Check your credentials."),
                backgroundColor: Colors.redAccent
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We "watch" the loading state to show a spinner during the network call.
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey, // Connects the validation logic to this form
          child: Column(
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),
              const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // 📧 EMAIL INPUT
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                ),
                validator: (val) => val!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 20),

              // 🔒 PASSWORD INPUT
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible, // Hides password with dots
                decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Refreshes the eye icon when clicked
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                ),
                validator: (val) => val!.length < 6 ? "Minimum 6 chars" : null,
              ),
              const SizedBox(height: 40),

              // 🔄 ACTION BUTTON OR SPINNER
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _handleLogin,
                  child: const Text("Sign In", style: TextStyle(fontSize: 18))
              ),
            ],
          ),
        ),
      ),
    );
  }
}