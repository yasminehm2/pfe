import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Last resort fallback if GPS is totally disabled
  final LatLng _sfaxFallback = const LatLng(34.74, 10.76);

  AuthProvider(this._repository);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Helper: Fetches high-accuracy coordinates with a 10s timeout
  Future<LatLng> _getDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _sfaxFallback;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _sfaxFallback;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Location error: $e");
      return _sfaxFallback;
    }
  }

  // Inside AuthProvider class
  Future<LatLng?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // 🚀 Step 1: Get the high-accuracy coordinates
      LatLng location = await _getDeviceLocation();

      // 🚀 Step 2: Send them to Spring Boot during account creation
      _currentUser = await _repository.signup(
        name: name,
        email: email,
        password: password,
        lat: location.latitude,
        lon: location.longitude,
      );

      notifyListeners();
      return location; // 🚀 Return the coordinates (Same as Login)
    } catch (e) {
      _errorMessage = "Signup failed. Email might already exist.";
      notifyListeners();
      return null; // Return null if it fails
    } finally {
      _setLoading(false);
    }
  }

// Inside AuthProvider.dart
  Future<LatLng?> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _repository.login(email, password);
      _currentUser = response;

      LatLng location = await _getDeviceLocation();

      // 🚀 Make sure 'email' here matches the one used for login
      await _repository.updateUserLocation(
        email: email,
        lat: location.latitude,
        lon: location.longitude,
      );

      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = "Login failed";
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<LatLng?> continueAsGuest() async {
    _setLoading(true);
    try {
      _currentUser = await _repository.enterAsGuest();
      return await _getDeviceLocation();
    } catch (e) {
      return _sfaxFallback;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}