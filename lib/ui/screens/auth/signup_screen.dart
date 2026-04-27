import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/map_provider.dart';

/**
 * 📝 THE SIGNUP SCREEN:
 * This widget allows new passengers to register.
 * It combines user input with real-time GPS data for the backend.
 */
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 🔑 FORM MANAGEMENT: Validates that all fields are filled correctly.
  final _formKey = GlobalKey<FormState>();

  // ✍️ INPUT TRACKERS: Capture name, email, and password.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 👁️ UI TOGGLE: Shows or hides the password characters.
  bool _isPasswordVisible = false;

  /**
   * 🚀 THE REGISTRATION LOGIC:
   * Sends user data + current GPS coordinates to the server.
   */
  Future<void> _handleSignup() async {
    // 1. Validate fields (e.g., check for '@' in email and password length).
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = context.read<AuthProvider>();

      // 2. Call the AuthProvider to perform the network request.
      // Note: signup() internally triggers the GPS permission request.
      final LatLng? location = await authProvider.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. SUCCESS FLOW:
      if (location != null && mounted) {
        final mapProvider = context.read<MapProvider>();

        // 🧹 MAP SETUP: Reset map state and center on the user's current street.
        mapProvider.resetMap();
        mapProvider.updateCenter(location);

        // ⭐ FAVORITES SETUP:
        // Registers the new User ID in the Favorites system (starts empty).
        if (authProvider.currentUser != null) {
          await mapProvider.loadFavorites(authProvider.currentUser!.id);
        }

        // 🗺️ NAVIGATION: Go to main map and lock the user out of the signup screen history.
        Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
      }
    } catch (e) {
      // ❌ ERROR HANDLING: Catch existing emails or server timeouts.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Email already exists or network error."),
                backgroundColor: Colors.redAccent
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listens for the loading state to switch between the button and the spinner.
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey, // Connects the validation logic.
          child: Column(
            children: [
              // 👤 NAME FIELD
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 20),

              // 📧 EMAIL FIELD
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                validator: (val) => !val!.contains("@") ? "Invalid email" : null,
              ),
              const SizedBox(height: 20),

              // 🔒 PASSWORD FIELD
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (val) => val!.length < 6 ? "Minimum 6 chars" : null,
              ),
              const SizedBox(height: 40),

              // 🔄 ACTION BUTTON
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _handleSignup,
                  child: const Text("Register", style: TextStyle(fontSize: 18))
              ),
            ],
          ),
        ),
      ),
    );
  }
}