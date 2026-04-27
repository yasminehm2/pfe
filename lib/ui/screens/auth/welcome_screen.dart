import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/map_provider.dart';

/**
 * 🏠 THE WELCOME SCREEN:
 * The entry point of the application. It handles branding and
 * redirects the user to the appropriate authentication flow.
 */
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // 🔄 UI STATE: Tracks the specific loading state for the Guest button
  bool _isGuestLoading = false;

  /**
   * 🚪 GUEST LOGIC:
   * Bypasses formal login to let the user see the map immediately.
   */
  Future<void> _handleGuestMode() async {
    setState(() => _isGuestLoading = true);
    final auth = context.read<AuthProvider>();
    final map = context.read<MapProvider>();

    try {
      // 1. Ask the backend for a temporary Guest ID and fetch current GPS location
      final LatLng? location = await auth.continueAsGuest();

      if (location != null && mounted) {
        // 🚀 THE FIX: Clean the map state (removes old markers/routes) before entering.
        // This ensures a fresh experience if a different user was logged in previously.
        map.resetMap();
        map.updateCenter(location);

        // 🗺️ NAVIGATION: Move to the Map and clear the navigation history.
        Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
      }
    } catch (e) {
      debugPrint("Guest login failed: $e");
    } finally {
      // Re-enable the button if the process finishes or fails
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // 🎨 VISUAL DESIGN: A blue gradient representing Sfax Transport branding
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🚌 LOGO SECTION
            const Icon(Icons.directions_bus, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text("Sfax Transport",
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Your city, your rhythm.",
                style: TextStyle(color: Colors.white70, fontSize: 16)),

            const SizedBox(height: 80),

            // 🔘 LOGIN BUTTON: Takes user to the Login screen
            _buildActionBtn("Login", Colors.white, Colors.blue.shade700,
                    () => Navigator.pushNamed(context, '/login')),

            const SizedBox(height: 15),

            // 🔘 SIGN UP BUTTON: Takes user to the Signup screen
            _buildActionBtn("Sign Up", Colors.blue.shade900, Colors.white,
                    () => Navigator.pushNamed(context, '/signup')),

            const SizedBox(height: 30),

            // 🔗 GUEST LINK: Shows a spinner if the guest session is being created
            _isGuestLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : TextButton(
              onPressed: _handleGuestMode,
              child: const Text("Continue as Guest",
                  style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 🛠️ BUTTON BUILDER:
   * A helper method to create consistent-looking buttons for the welcome screen.
   */
  Widget _buildActionBtn(String label, Color bg, Color text, VoidCallback action) {
    return SizedBox(
      width: 280, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        onPressed: action,
        child: Text(label, style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}