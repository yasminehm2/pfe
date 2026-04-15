import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    setState(() => _isLoading = true);
    try {
      Position? position = await LocationHelper.requestLocationPermission();
      if (position != null) {
        LatLng myLocation = LatLng(position.latitude, position.longitude);
        if (mounted) {
          context.read<MapProvider>().updateCenter(myLocation);
          // 🚀 Key: RemoveUntil clears the back arrow
          Navigator.pushNamedAndRemoveUntil(context, '/map', (route) => false);
        }
      } else {
        await SystemNavigator.pop();
      }
    } catch (e) {
      await SystemNavigator.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bus_alert, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text("Sfax Transport", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 60),
            _buildBtn(context, "Login", Colors.white, Colors.blue, '/login'),
            const SizedBox(height: 15),
            _buildBtn(context, "Create Account", Colors.blue.shade900, Colors.white, '/signup'),
            const SizedBox(height: 25),
            _isLoading
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

  Widget _buildBtn(BuildContext context, String text, Color bg, Color textCol, String route) {
    return SizedBox(
      width: 280, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(text, style: TextStyle(color: textCol, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}