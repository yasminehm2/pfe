// lib/logic/providers/tracking_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/live_tracking_model.dart';
import '../../data/repositories/tracking_repository.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingRepository _repository;

  Timer? _pollingTimer;
  LiveTrackingModel? _currentUpdate;

  bool _isLoading = false;
  String? _errorMessage;
  String? _activeRotationId;

  TrackingProvider(this._repository);

  LiveTrackingModel? get currentUpdate => _currentUpdate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTracking => _pollingTimer != null;

  /// 🚀 Combined action: Activates the tracking on the server AND starts polling
  Future<bool> activateAndTrack(String rotationId, String stationId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Confirm with backend
    bool success = await _repository.confirmTripTracking(rotationId, userId);

    if (success) {
      // 2. Start the live polling loop
      _startPolling(rotationId, stationId);
      return true;
    } else {
      _isLoading = false;
      _errorMessage = "Failed to activate tracking. Check your connection.";
      notifyListeners();
      return false;
    }
  }

  /// Internal method to start the periodic GPS/ETA fetches
  void _startPolling(String rotationId, String stationId) {
    if (_activeRotationId == rotationId && _pollingTimer != null) return;

    _stopInternalTimer();

    _activeRotationId = rotationId;
    _isLoading = true;
    notifyListeners();

    // Fetch immediately on start
    _fetchUpdate(rotationId, stationId, isInitialFetch: true);

    // Poll every 7 seconds for smooth movement and updated ETAs
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _fetchUpdate(rotationId, stationId, isInitialFetch: false);
    });
  }

  Future<void> _fetchUpdate(String rotationId, String stationId, {required bool isInitialFetch}) async {
    try {
      final update = await _repository.getLiveUpdate(rotationId, stationId);

      // Ensure we haven't stopped tracking while the network request was in flight
      if (_activeRotationId != rotationId) return;

      _currentUpdate = update;
      _errorMessage = null;
    } catch (e) {
      if (isInitialFetch) {
        _errorMessage = "Unable to reach tracking server. The bus might be offline.";
      }
      debugPrint("⚠️ Tracking Polling Error: $e");
    } finally {
      if (isInitialFetch) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Stops the polling loop and clears all live map data
  void stopTracking() {
    _stopInternalTimer();
    _isLoading = false; // 🚀 ADD THIS LINE TO FIX THE BUG
    _currentUpdate = null;
    _activeRotationId = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopInternalTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopInternalTimer();
    super.dispose();
  }
}