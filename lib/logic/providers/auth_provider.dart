// lib/logic/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Handles GPS hardware
import 'package:latlong2/latlong.dart';      // Coordinates math
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/**
 * 🧠 THE AUTH PROVIDER:
 * This class is the single source of truth for "Who is using the app?"
 * It handles logic that spans across multiple screens.
 */
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _currentUser;   // Stores the logged-in user data
  bool _isLoading = false;   // Shows/hides loading spinners in the UI
  String? _errorMessage;     // Stores text to show in snackbars if things fail

  // Temporary storage to remember what the user typed in case the backend is slow
  String? _typedName;
  String? _typedEmail;

  // 📍 SFAX FALLBACK: If the user denies GPS, we put them in Sfax city center.
  final LatLng _sfaxFallback = const LatLng(34.74, 10.76);

  AuthProvider(this._repository);

  // --- PUBLIC GETTERS ---
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Checks if the current ID is a real database ID or a "GUEST" tag.
  bool get isRealUser {
    if (_currentUser == null || _currentUser!.id.isEmpty) return false;
    return !_currentUser!.id.toString().toUpperCase().contains("GUEST");
  }

  // Logic to decide what email to show in the Profile Drawer.
  String get displayEmail {
    if (!isRealUser) return "Sfax Public Transport";
    final backendEmail = _currentUser?.email ?? "";
    return backendEmail.isNotEmpty ? backendEmail : (_typedEmail ?? "");
  }

  // Logic to decide what name to show in the UI.
  String get displayName {
    if (!isRealUser) return "Guest";
    final backendName = _currentUser?.name ?? "";
    if (backendName.isNotEmpty && backendName.toLowerCase() != 'guest') return backendName;
    if (_typedName != null && _typedName!.isNotEmpty) return _typedName!;
    // If no name, use the first part of the email.
    if (_typedEmail != null && _typedEmail!.contains('@')) return _typedEmail!.split('@')[0];
    return "Passenger";
  }

  /**
   * 📡 GPS HELPER:
   * Asks the phone for permission and returns the current Latitude/Longitude.
   */
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

  /**
   * 📝 SIGNUP LOGIC:
   * Gets GPS location first, then sends everything to the Spring Boot backend.
   */
  Future<LatLng?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _typedName = name;
    _typedEmail = email;

    try {
      LatLng location = await _getDeviceLocation();
      _currentUser = await _repository.signup(
        name: name,
        email: email,
        password: password,
        lat: location.latitude,
        lon: location.longitude,
      );
      notifyListeners(); // Tells the UI: "User is logged in now!"
      return location;
    } catch (e) {
      _errorMessage = "Signup failed.";
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /**
   * 🔑 LOGIN LOGIC:
   * Authenticates, gets current location, and then updates the backend
   * with the user's latest position.
   */
  Future<LatLng?> login(String email, String password) async {
    _setLoading(true);
    _typedEmail = email;
    _typedName = null;

    try {
      final response = await _repository.login(email, password);
      _currentUser = response;
      LatLng location = await _getDeviceLocation();

      // 🚀 UPDATED: Notifies the Sfax database where the passenger is standing.
      if (_currentUser != null) {
        await _repository.updateUserLocation(
          userId: _currentUser!.id,
          lat: location.latitude,
          lon: location.longitude,
        );
      }

      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = "Login failed";
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /**
   * 🚪 GUEST LOGIC:
   * Allows entry without an account while still tracking the guest's
   * initial position for "Nearby Stations" math.
   */
  Future<LatLng?> continueAsGuest() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUser = await _repository.enterAsGuest();
      LatLng location = await _getDeviceLocation();

      if (_currentUser != null) {
        await _repository.updateUserLocation(
          userId: _currentUser!.id,
          lat: location.latitude,
          lon: location.longitude,
        );
      }

      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = "Guest access failed.";
      return _sfaxFallback;
    } finally {
      _setLoading(false);
    }
  }

  // Helper to change loading state and refresh UI.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /**
   * 🗑️ LOGOUT:
   * Clears all session data and wipes the "Brain" clean.
   */
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _typedName = null;
    _typedEmail = null;
    _isLoading = false;
    notifyListeners();
    debugPrint("User logged out. Session cleared.");
  }
}