// lib/logic/providers/map_provider.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🚀 IMPORT ADDED
import '../../data/models/station_model.dart';
import '../../data/models/rotation_model.dart';
import '../../data/repositories/map_repository.dart';

class MapProvider extends ChangeNotifier {
  final MapRepository _repository;

  MapProvider(this._repository);

  // --- State Variables ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StationModel> _allStations = [];
  List<StationModel> get allStations => _allStations;

  List<Marker> _stationMarkers = [];
  List<Marker> get allMarkers => _stationMarkers;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;
  set routePoints(List<LatLng> val) {
    _routePoints = val;
    notifyListeners();
  }

  LatLng? _liveBusLocation;
  LatLng? get liveBusLocation => _liveBusLocation;

  List<RotationModel> _selectedStationTrips = [];
  List<RotationModel> get selectedStationTrips => _selectedStationTrips;

  List<StationModel> _currentItinerary = [];
  List<StationModel> get currentItinerary => _currentItinerary;

  final List<RotationModel> _favoriteTrips = [];
  List<RotationModel> get favoriteTrips => _favoriteTrips;

  LatLng _currentViewCenter = const LatLng(34.727, 10.718);
  LatLng get currentViewCenter => _currentViewCenter;

  Function(String, String)? onStationSelected;

  // 🚀 NEW: Tracks whose favorites are currently loaded
  String? _currentUserId;

  // --- Favourites Logic ---

  // 🚀 NEW: Loads the specific user's saved favorites from the phone
  Future<void> loadFavorites(String userId) async {
    _currentUserId = userId;
    _favoriteTrips.clear();

    // Guests do not get favorites. Exit early.
    if (userId.toUpperCase().contains('GUEST')) {
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? favString = prefs.getString('favorites_$userId'); // Fetch by ID

    if (favString != null) {
      final List decoded = json.decode(favString);
      _favoriteTrips.addAll(decoded.map((e) => RotationModel.fromJson(e)).toList());
    }
    notifyListeners();
  }

  // 🚀 NEW: Saves the current user's list to the phone
  Future<void> _saveFavoritesToStorage() async {
    if (_currentUserId == null || _currentUserId!.toUpperCase().contains('GUEST')) return;

    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_favoriteTrips.map((e) => e.toJson()).toList());
    await prefs.setString('favorites_$_currentUserId', encoded); // Save by ID
  }

  bool isFavorite(String tripId) {
    return _favoriteTrips.any((trip) => trip.id == tripId);
  }

  void toggleFavorite(RotationModel trip) {
    if (isFavorite(trip.id!)) {
      _favoriteTrips.removeWhere((t) => t.id == trip.id);
    } else {
      _favoriteTrips.add(trip);
    }
    _saveFavoritesToStorage(); // 🚀 Persist changes locally instantly
    notifyListeners();
  }

  // --- Logic Methods ---
  void updateCenter(LatLng newCenter) {
    _currentViewCenter = newCenter;
    notifyListeners();
  }

  void resetMap() {
    _routePoints = [];
    _liveBusLocation = null;
    _currentItinerary = [];
    _selectedStationTrips = [];
    _stationMarkers = [];
    _allStations = [];
    _favoriteTrips.clear(); // 🚀 CLEAR FAVORITES ON LOGOUT
    _currentUserId = null; // 🚀 CLEAR USER ID
    notifyListeners();
  }

  void clearTrackingVisuals() {
    _routePoints = [];
    _liveBusLocation = null;
    _currentItinerary = [];
    notifyListeners();
  }

  void updateBusLocation(double lat, double lon) {
    _liveBusLocation = LatLng(lat, lon);
    notifyListeners();
  }

  Future<void> fetchNearbyStations(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<StationModel> stationsFromDb = await _repository.getNearbyStations(lat, lon);
      final String fetchId = DateTime.now().millisecondsSinceEpoch.toString();

      final List<Marker> newMarkers = stationsFromDb.map((station) {
        return Marker(
          key: ValueKey("marker_${station.id}_$fetchId"),
          point: LatLng(station.latitude, station.longitude),
          width: 160,
          height: 120,
          child: Center(
            child: GestureDetector(
              key: ValueKey("tap_${station.id}_$fetchId"),
              behavior: HitTestBehavior.opaque,
              onTap: () => onStationSelected?.call(station.id, station.nameFr),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStationLabel(station.nameAr, station.nameFr),
                  const Icon(Icons.location_on, color: Colors.red, size: 32),
                ],
              ),
            ),
          ),
        );
      }).toList();

      _stationMarkers = newMarkers;
      _allStations = stationsFromDb;
    } catch (e) {
      debugPrint("❌ Map Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTripsForStation(String stationId) async {
    _isLoading = true;
    _selectedStationTrips = [];
    notifyListeners();
    try {
      _selectedStationTrips = await _repository.getTripsForStation(stationId);
    } catch (e) {
      debugPrint("❌ Trip Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTripItinerary(String rotationId) async {
    _isLoading = true;
    _currentItinerary = [];
    _routePoints = [];
    notifyListeners();
    try {
      _currentItinerary = await _repository.getTripItinerary(rotationId);

      if (_currentItinerary.isNotEmpty) {
        _liveBusLocation = LatLng(_currentItinerary.first.latitude, _currentItinerary.first.longitude);
        await _fetchRoadAlignedPath(_currentItinerary);
      }
    } catch (e) {
      debugPrint("❌ Itinerary Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchRoadAlignedPath(List<StationModel> stations) async {
    if (stations.length < 2) return;
    final String coords = stations.map((s) => "${s.longitude},${s.latitude}").join(';');
    final url = 'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordsList = data['routes'][0]['geometry']['coordinates'];
        _routePoints = coordsList.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
        notifyListeners();
      }
    } catch (e) {
      _routePoints = stations.map((s) => LatLng(s.latitude, s.longitude)).toList();
      notifyListeners();
    }
  }

  Future<void> getRoute(LatLng start, LatLng end) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List coords = data['routes'][0]['geometry']['coordinates'];
          _routePoints = coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          notifyListeners();
        }
      }
    } catch (e) { debugPrint("❌ Routing Error: $e"); }
  }

  Widget _buildStationLabel(String ar, String fr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        children: [
          Text(ar, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          Text(fr, style: const TextStyle(fontSize: 8, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    onStationSelected = null;
    super.dispose();
  }
}