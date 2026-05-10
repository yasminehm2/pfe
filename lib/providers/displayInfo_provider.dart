// lib/logic/providers/display_info_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/station_model.dart';
import '../../data/models/displayInfo_model.dart';
import '../../data/repositories/displayInfo_repository.dart';
import '../../data/repositories/station_repository.dart';

class DisplayInfoProvider extends ChangeNotifier {
  final DisplayInfoRepository _displayRepo;
  final StationRepository _stationRepo; // Needed for itinerary fetching

  DisplayInfoProvider(this._displayRepo, this._stationRepo);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DisplayInfoModel> _selectedStationTrips = [];
  List<DisplayInfoModel> get selectedStationTrips => _selectedStationTrips;

  List<StationModel> _currentItinerary = [];
  List<StationModel> get currentItinerary => _currentItinerary;

  final List<DisplayInfoModel> _favoriteTrips = [];
  List<DisplayInfoModel> get favoriteTrips => _favoriteTrips;

  LatLng? _liveBusLocation;
  LatLng? get liveBusLocation => _liveBusLocation;

  String? _currentUserId;
  String? _trackedStationId;
  int _cameraMoveTrigger = 0;
  int get cameraMoveTrigger => _cameraMoveTrigger;

  void setTrackedStation(String stationId) {
    _trackedStationId = stationId;
    notifyListeners();
  }

  void triggerCameraToBus() {
    _cameraMoveTrigger++;
    notifyListeners();
  }

  List<Marker> get itineraryTimeLabels {
    return _currentItinerary
        .where((s) => s.id == _trackedStationId)
        .map((station) {
      String label = "${station.minutesFromStartStation ?? 0} min";
      Color bgColor = Colors.blue[900]!;

      if (station.hasPassed) {
        label = "Passed";
        bgColor = Colors.grey[700]!;
      } else if (station.liveEtaMinutes != null) {
        label = "${station.liveEtaMinutes} min";
        bgColor = Colors.green[700]!;
      }

      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 75,
        height: 35,
        alignment: const Alignment(0, -2.5),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }

  Future<void> fetchTripsForStation(String stationId) async {
    _isLoading = true;
    _selectedStationTrips = [];
    notifyListeners();
    try {
      _selectedStationTrips = await _displayRepo.getTripsForStation(stationId);
    } catch (e) {
      debugPrint("❌ Trip Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<StationModel>> fetchTripItinerary(String rotationId) async {
    _isLoading = true;
    _currentItinerary = [];
    notifyListeners();
    try {
      _currentItinerary = await _stationRepo.getTripItinerary(rotationId);
      if (_currentItinerary.isNotEmpty) {
        _liveBusLocation = LatLng(_currentItinerary.first.latitude, _currentItinerary.first.longitude);
      }
      return _currentItinerary;
    } catch (e) {
      debugPrint("❌ Itinerary Sync Error: $e");
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFromLiveTracking(Map<String, dynamic> json) {
    if (json['vehicleLat'] != null && json['vehicleLon'] != null) {
      _liveBusLocation = LatLng(
        (json['vehicleLat'] as num).toDouble(),
        (json['vehicleLon'] as num).toDouble(),
      );
    }
    if (json['itinerary'] != null) {
      final List itineraryData = json['itinerary'];
      _currentItinerary = itineraryData.map((item) => StationModel.fromJson(item)).toList();
    }
    notifyListeners();
  }

  // --- Favorites Logic ---
  Future<void> loadFavorites(String userId) async {
    _currentUserId = userId;
    _favoriteTrips.clear();
    if (userId.toUpperCase().contains('GUEST')) {
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final String? favString = prefs.getString('favorites_$userId');
    if (favString != null) {
      final List decoded = json.decode(favString);
      _favoriteTrips.addAll(decoded.map((e) => DisplayInfoModel.fromJson(e)).toList());
    }
    notifyListeners();
  }

  void toggleFavorite(DisplayInfoModel trip) {
    if (favoriteTrips.any((t) => t.id == trip.id)) {
      _favoriteTrips.removeWhere((t) => t.id == trip.id);
    } else {
      _favoriteTrips.add(trip);
    }
    _saveFavoritesToStorage();
    notifyListeners();
  }

  Future<void> _saveFavoritesToStorage() async {
    if (_currentUserId == null || _currentUserId!.toUpperCase().contains('GUEST')) return;
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_favoriteTrips.map((e) => e.toJson()).toList());
    await prefs.setString('favorites_$_currentUserId', encoded);
  }

  void clearTrackingVisuals() {
    _liveBusLocation = null;
    _currentItinerary = [];
    _trackedStationId = null;
    notifyListeners();
  }
}