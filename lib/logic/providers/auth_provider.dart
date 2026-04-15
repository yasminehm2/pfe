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

      await _repository.updateUserLocation(
        email: email,
        lat: location.latitude,
        lon: location.longitude,
      );

      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = "Login failed";
      notifyListeners(); // 🚀 Important to notify listeners of the error message
      rethrow; // 🚀 ADD THIS: This triggers the catch block in LoginScreen.dart
    } finally {
      _setLoading(false);
    }
  }

  Future<LatLng?> continueAsGuest() async {
    _setLoading(true);
    _errorMessage = null; // Clear previous errors

    try {
      // 1. Authenticate with Spring Boot as a Guest
      _currentUser = await _repository.enterAsGuest();

      // 2. 🚀 Step 2: Get high-accuracy coordinates (Same as Login/Signup)
      LatLng location = await _getDeviceLocation();

      // 3. 🚀 Step 3: Update the Guest's location in the database
      // Using the guest's email/ID retrieved from the response
      if (_currentUser != null) {
        await _repository.updateUserLocation(
          email: _currentUser!.email,
          lat: location.latitude,
          lon: location.longitude,
        );
      }

      notifyListeners();
      return location; // Return the coordinates to move the map
    } catch (e) {
      debugPrint("Guest Mode Error: $e");
      _errorMessage = "Guest access failed. Please check your connection.";

      // Fallback to Sfax if everything fails so the map still opens
      return _sfaxFallback;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  /// 🚀 Clears the session and notifies listeners to update the UI
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    _isLoading = false;

    // Optionally: If your repository handles local storage (SharedPreferences/SecureStorage),
    // call a clear method there too.
    // await _repository.clearSession();

    notifyListeners();
    debugPrint("User logged out. Session cleared.");
  }
}