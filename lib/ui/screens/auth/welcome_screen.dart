import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/station_provider.dart';
import '../../../providers/displayInfo_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isGuestLoading = false;

  Future<void> _handleGuestMode() async {
    setState(() => _isGuestLoading = true);
    final user = context.read<UserProvider>();
    final stationProvider = context.read<StationProvider>();
    final displayProvider = context.read<DisplayInfoProvider>();

    try {
      final LatLng? location = await user.continueAsGuest();

      if (location != null && mounted) {
        stationProvider.resetMap();
        displayProvider.clearTrackingVisuals();
        stationProvider.updateCenter(location);
        Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
      }
    } catch (e) {
      debugPrint("Guest login failed: $e");
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 Extract theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor], // 🚀 Using Theme!
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text("Sfax Transport", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Your city, your rhythm.", style: TextStyle(color: Colors.white70, fontSize: 16)),

            const SizedBox(height: 80),

            // Using white background with Primary text
            _buildActionBtn("Login", Colors.white, primaryColor, () => Navigator.pushNamed(context, '/login')),

            const SizedBox(height: 15),

            // Using Primary background with White text (we make it slightly darker than the gradient)
            _buildActionBtn("Sign Up", primaryColor.withOpacity(0.9), Colors.white, () => Navigator.pushNamed(context, '/signup')),

            const SizedBox(height: 30),

            _isGuestLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : TextButton(
              onPressed: _handleGuestMode,
              child: const Text("Continue as Guest", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, Color bg, Color text, VoidCallback action) {
    return SizedBox(
      width: 280, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: text,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        onPressed: action,
        child: Text(label),
      ),
    );
  }
}