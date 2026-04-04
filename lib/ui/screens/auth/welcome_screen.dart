import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/utils/location_helper.dart';
import '../../../logic/providers/map_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _handleGuestMode() async {
    // 1. Show loading (optional but recommended)
    setState(() => _isLoading = true);

    // 2. Navigate immediately (NO BLOCKING)
    Navigator.pushReplacementNamed(context, '/map');

    // 3. Fetch location in background
    Future.delayed(Duration.zero, () async {
      Position? position;
      try {
        position = await LocationHelper.requestLocationPermission();
      } catch (e) {
        debugPrint("Guest location error: $e");
      }

      // 4. Default location (Sfax)
      LatLng targetLocation = const LatLng(34.74, 10.76);

      if (position != null) {
        targetLocation = LatLng(position.latitude, position.longitude);
      }

      // 5. Update provider safely
      if (mounted) {
        Provider.of<MapProvider>(context, listen: false)
            .updateCenter(targetLocation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bus_alert, size: 80, color: Colors.white),
              const SizedBox(height: 20),

              const Text(
                "Sfax Transport",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Real-time bus tracking at your fingertips",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 60),

              _buildActionButton(
                context,
                "Login",
                Colors.white,
                Colors.blue,
                '/login',
              ),

              const SizedBox(height: 15),

              _buildActionButton(
                context,
                "Create Account",
                Colors.blue.shade900,
                Colors.white,
                '/signup',
              ),

              const SizedBox(height: 25),

              // ✅ Guest Mode (fixed)
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : TextButton(
                onPressed: _handleGuestMode,
                child: const Text(
                  "Continue as Guest",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String text,
      Color bg,
      Color textCol,
      String route,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          text,
          style: TextStyle(
            color: textCol,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}