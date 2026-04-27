import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/station_model.dart';
import '../../data/models/displayInfo_model.dart';
import '../../data/repositories/map_repository.dart';

class MapProvider extends ChangeNotifier {
  final MapRepository _repository;

  MapProvider(this._repository);

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

  List<DisplayInfoModel> _selectedStationTrips = [];
  List<DisplayInfoModel> get selectedStationTrips => _selectedStationTrips;

  List<StationModel> _currentItinerary = [];
  List<StationModel> get currentItinerary => _currentItinerary;

  final List<DisplayInfoModel> _favoriteTrips = [];
  List<DisplayInfoModel> get favoriteTrips => _favoriteTrips;

  LatLng _currentViewCenter = const LatLng(34.727, 10.718);
  LatLng get currentViewCenter => _currentViewCenter;

  Function(String, String)? onStationSelected;
  String? _currentUserId;

  // 🚀 TRACKED STATION LOGIC
  String? _trackedStationId;
  int _cameraMoveTrigger = 0;
  int get cameraMoveTrigger => _cameraMoveTrigger;

  void triggerCameraToBus() {
    _cameraMoveTrigger++;
    notifyListeners();
  }

  // 🚀 Set the specific station the user is boarding from
  void setTrackedStation(String stationId) {
    _trackedStationId = stationId;
    notifyListeners();
  }

  // 🚀 Filtered labels for the map (Only shows the boarding station)
  List<Marker> get itineraryTimeLabels {
    return _currentItinerary
        .where((s) => s.id == _trackedStationId) // 🎯 THE FILTER
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
        child: IgnorePointer(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }).toList();
  }

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

  Future<void> _saveFavoritesToStorage() async {
    if (_currentUserId == null || _currentUserId!.toUpperCase().contains('GUEST')) return;
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_favoriteTrips.map((e) => e.toJson()).toList());
    await prefs.setString('favorites_$_currentUserId', encoded);
  }

  bool isFavorite(String tripId) => _favoriteTrips.any((trip) => trip.id == tripId);

  void toggleFavorite(DisplayInfoModel trip) {
    if (isFavorite(trip.id!)) {
      _favoriteTrips.removeWhere((t) => t.id == trip.id);
    } else {
      _favoriteTrips.add(trip);
    }
    _saveFavoritesToStorage();
    notifyListeners();
  }

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
    _favoriteTrips.clear();
    _currentUserId = null;
    _trackedStationId = null; // Clear tracking
    notifyListeners();
  }

  void clearTrackingVisuals() {
    _routePoints = [];
    _liveBusLocation = null;
    _currentItinerary = [];
    _trackedStationId = null; // Clear tracking
    notifyListeners();
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

  Future<void> fetchNearbyStations(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<StationModel> stationsFromDb = await _repository.getNearbyStations(lat, lon);
      final String fetchId = DateTime.now().millisecondsSinceEpoch.toString();
      _stationMarkers = stationsFromDb.map((station) {
        return Marker(
          key: ValueKey("marker_${station.id}_$fetchId"),
          point: LatLng(station.latitude, station.longitude),
          width: 160,
          height: 120,
          child: Center(
            child: GestureDetector(
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
        triggerCameraToBus();
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
}