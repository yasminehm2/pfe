// lib/core/utils/location_helper.dart
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<Position?> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled on the device
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // 2. Check current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 3. Trigger the actual system popup
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // 4. Return current position to initialize the Map center
    return await Geolocator.getCurrentPosition();
  }
}