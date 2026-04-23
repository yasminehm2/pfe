// lib/logic/providers/auth_provider.dart

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

  String? _typedName;
  String? _typedEmail;

  final LatLng _sfaxFallback = const LatLng(34.74, 10.76);

  AuthProvider(this._repository);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  bool get isRealUser {
    if (_currentUser == null || _currentUser!.id.isEmpty) return false;
    return !_currentUser!.id.toString().toUpperCase().contains("GUEST");
  }

  String get displayEmail {
    if (!isRealUser) return "Sfax Public Transport";
    final backendEmail = _currentUser?.email ?? "";
    return backendEmail.isNotEmpty ? backendEmail : (_typedEmail ?? "");
  }

  String get displayName {
    if (!isRealUser) return "Guest";
    final backendName = _currentUser?.name ?? "";
    if (backendName.isNotEmpty && backendName.toLowerCase() != 'guest') return backendName;
    if (_typedName != null && _typedName!.isNotEmpty) return _typedName!;
    if (_typedEmail != null && _typedEmail!.contains('@')) return _typedEmail!.split('@')[0];
    return "Passenger";
  }

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
      notifyListeners();
      return location;
    } catch (e) {
      _errorMessage = "Signup failed.";
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<LatLng?> login(String email, String password) async {
    _setLoading(true);

    _typedEmail = email;
    _typedName = null;

    try {
      final response = await _repository.login(email, password);
      _currentUser = response;
      LatLng location = await _getDeviceLocation();

      // 🚀 UPDATED: Uses ID instead of email
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

  Future<LatLng?> continueAsGuest() async {
    _setLoading(true);
    _errorMessage = null;

    _typedName = null;
    _typedEmail = null;

    try {
      _currentUser = await _repository.enterAsGuest();
      LatLng location = await _getDeviceLocation();

      // 🚀 UPDATED: Uses ID instead of email
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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