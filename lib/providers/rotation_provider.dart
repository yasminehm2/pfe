// lib/logic/providers/tracking_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/rotation_model.dart';
import '../data/repositories/rotation_repository.dart';


/**
 * 🛰️ THE TRACKING PROVIDER:
 * This class handles the "Live" state. It uses a Timer to refresh data
 * automatically so the user doesn't have to keep clicking a refresh button.
 */
class RotationProvider extends ChangeNotifier {
  final RotationRepository _repository;

  Timer? _pollingTimer; // The "Clock" that triggers updates every few seconds
  RotationModel? _currentUpdate; // Stores the latest GPS/ETA data

  bool _isLoading = false;
  String? _errorMessage;
  String? _activeRotationId; // Tracks which specific bus trip we are watching

  RotationProvider(this._repository);

  // --- Getters to expose state to the UI ---
  RotationModel? get currentUpdate => _currentUpdate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTracking => _pollingTimer != null; // True if the timer is currently running

  /**
   * 🚀 START TRACKING:
   * 1. Tells the server we are interested in this trip.
   * 2. Starts the clock (Timer) to get updates.
   */
  Future<bool> activateAndTrack(String rotationId, String stationId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Confirm with backend (The "Handshake")
    bool success = await _repository.confirmTripTracking(rotationId, userId);

    if (success) {
      // 2. Start the live polling loop (Step-by-step update)
      _startPolling(rotationId, stationId);
      return true;
    } else {
      _isLoading = false;
      _errorMessage = "Failed to activate tracking. Check your connection.";
      notifyListeners();
      return false;
    }
  }

  /**
   * 🕒 THE POLLING ENGINE:
   * Sets up a Timer that repeats every 7 seconds.
   */
  void _startPolling(String rotationId, String stationId) {
    // Safety check: Don't start a second timer if one is already running for this trip
    if (_activeRotationId == rotationId && _pollingTimer != null) return;

    _stopInternalTimer(); // Clean up any old timers

    _activeRotationId = rotationId;
    _isLoading = true;
    notifyListeners();

    // First fetch happens immediately so the user doesn't wait 7 seconds for the first icon
    _fetchUpdate(rotationId, stationId, isInitialFetch: true);

    // Poll every 7 seconds for smooth movement and updated ETAs
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _fetchUpdate(rotationId, stationId, isInitialFetch: false);
    });
  }

  /**
   * 🛰️ DATA FETCH:
   * Asks the repository for the latest 'LiveTrackingModel'.
   */
  Future<void> _fetchUpdate(String rotationId, String stationId, {required bool isInitialFetch}) async {
    try {
      final update = await _repository.getLiveUpdate(rotationId, stationId);

      // Ensure we haven't stopped tracking or switched trips while the internet request was traveling
      if (_activeRotationId != rotationId) return;

      _currentUpdate = update;
      _errorMessage = null;
    } catch (e) {
      // If the very first fetch fails, show a big error.
      // If a middle fetch fails, we stay quiet and hope the next one works (it might be a temporary tunnel).
      if (isInitialFetch) {
        _errorMessage = "Unable to reach tracking server. The bus might be offline.";
      }
      debugPrint("⚠️ Tracking Polling Error: $e");
    } finally {
      if (isInitialFetch) {
        _isLoading = false;
      }
      notifyListeners(); // Refresh the map/UI with new coordinates
    }
  }

  /**
   * 🛑 STOP TRACKING:
   * Kills the timer and wipes the data from the screen.
   */
  void stopTracking() {
    _stopInternalTimer();
    _isLoading = false;
    _currentUpdate = null;
    _activeRotationId = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Internal helper to cancel the timer safely
  void _stopInternalTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Called when the app closes to make sure we don't waste battery/data
  @override
  void dispose() {
    _stopInternalTimer();
    super.dispose();
  }
}