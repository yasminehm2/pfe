import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/live_tracking_model.dart';
import '../../data/repositories/tracking_repository.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingRepository _repository;

  // Internal State
  Timer? _pollingTimer;
  LiveTrackingModel? _currentUpdate;
  bool _isLoading = false;
  String? _errorMessage;

  // Track the current active IDs to prevent duplicate loops
  String? _activeRotationId;

  TrackingProvider(this._repository);

  // Getters
  LiveTrackingModel? get currentUpdate => _currentUpdate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTracking => _pollingTimer != null;

  /// Starts the 7-second polling loop.
  /// If already tracking the same rotation, it does nothing.
  void startLiveTracking(String rotationId, String stationId) {
    // Prevent restarting the same loop if it's already running
    if (_activeRotationId == rotationId && _pollingTimer != null) return;

    _stopInternalTimer(); // Clean up any existing tracking

    _activeRotationId = rotationId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Immediate first fetch to show data to the user right away
    _fetchUpdate(rotationId, stationId, isInitialFetch: true);

    // 2. Set up the periodic timer for subsequent background updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      _fetchUpdate(rotationId, stationId, isInitialFetch: false);
    });
  }

  /// Private method to handle the API call logic
  Future<void> _fetchUpdate(String rotationId, String stationId, {required bool isInitialFetch}) async {
    try {
      final update = await _repository.getLiveUpdate(rotationId, stationId);

      // Safety check: only update if we haven't switched rotations during the async call
      if (_activeRotationId != rotationId) return;

      _currentUpdate = update;
      _errorMessage = null;
    } catch (e) {
      // We only show the error UI if the initial fetch fails.
      // For background updates, we fail silently or log to avoid interrupting the user.
      if (isInitialFetch) {
        _errorMessage = "Unable to reach tracking server.";
      }
      debugPrint("Tracking Error: $e");
    } finally {
      if (isInitialFetch) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  /// Stops the timer and resets the state.
  /// Call this when the user closes the bus detail view or leaves the map.
  void stopTracking() {
    _stopInternalTimer();
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