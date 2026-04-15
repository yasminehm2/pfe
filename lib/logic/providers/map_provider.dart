import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/station_model.dart';
import '../../data/models/rotation_model.dart';
import '../../data/repositories/map_repository.dart';

class MapProvider extends ChangeNotifier {
  final MapRepository _repository;

  // 🚀 Centralized Dio instance for Spring Boot API
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://192.168.100.8:8080",
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

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

  List<RotationModel> _selectedStationTrips = [];
  List<RotationModel> get selectedStationTrips => _selectedStationTrips;

  LatLng _currentViewCenter = const LatLng(34.727, 10.718);
  LatLng get currentViewCenter => _currentViewCenter;

  Function(String, String)? onStationSelected;

  void updateCenter(LatLng newCenter) {
    _currentViewCenter = newCenter;
    notifyListeners();
  }

  /// 🚀 Fetch Nearby Stations and generate markers
  // Inside MapProvider.dart

  Future<void> fetchNearbyStations(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Call your Spring Boot API (which uses the MapService you just shared)
      final List<StationModel> stationsFromDb = await _repository.getNearbyStations(lat, lon);

      // 2. 🚀 CRITICAL: Clear and Replace.
      // Do NOT use .add() or .addAll() here, or you will see duplicate/old markers.
      _stationMarkers = stationsFromDb.map((station) {
        return Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 100,
          height: 80,
          child: GestureDetector(
            onTap: () => onStationSelected?.call(station.id, station.nameFr),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStationLabel(station.nameAr, station.nameFr),
                const Icon(Icons.location_on, color: Colors.red, size: 35),
              ],
            ),
          ),
        );
      }).toList();

      // 3. Update your local list for the search/autocomplete feature
      _allStations = stationsFromDb;

      debugPrint("📡 Displaying ${_stationMarkers.length} markers from your SQL database.");
    } catch (e) {
      debugPrint("❌ Map Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🚀 Fetch Real-time trip board for a specific station
  Future<void> fetchTripsForStation(String stationId) async {
    _isLoading = true;
    _selectedStationTrips = [];
    notifyListeners();

    try {
      // 🚀 Changed _client.dio to _dio to match your field name
      final response = await _dio.get("${ApiConstants.stationTrips}/$stationId/trips");

      if (response.statusCode == 200) {
        final List data = response.data;
        _selectedStationTrips = data.map((json) => RotationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("❌ Trip Board Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🚀 Fetch OSRM Road-following polyline
  Future<void> getRoute(LatLng start, LatLng end) async {
    _isLoading = true;
    _routePoints = []; // 🚀 Clear old route immediately
    notifyListeners();

    // OSRM expects {longitude},{latitude}
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List coordinates = data['routes'][0]['geometry']['coordinates'];

          // OSRM returns [lon, lat], FlutterMap needs [lat, lon]
          _routePoints = coordinates.map((c) =>
              LatLng(c[1].toDouble(), c[0].toDouble())
          ).toList();

          debugPrint("🚀 Route found: ${_routePoints.length} points");
        } else {
          debugPrint("⚠️ No route found in OSRM response");
        }
      }
    } catch (e) {
      debugPrint("❌ Routing Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // 🚀 This triggers the blue line to draw
    }
  }
  Widget _buildStationLabel(String ar, String fr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(ar, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
          Text(fr, style: const TextStyle(fontSize: 8, color: Colors.blueAccent)),
        ],
      ),
    );
  }
// lib/logic/providers/map_provider.dart

  List<StationModel> _currentItinerary = [];
  List<StationModel> get currentItinerary => _currentItinerary;

  Future<void> fetchTripItinerary(String rotationId) async {
    _isLoading = true;
    _currentItinerary = []; // Clear previous itinerary
    notifyListeners();

    try {
      // 🚀 Using your existing _dio instance
      final response = await _dio.get("/api/stations/trips/$rotationId/itinerary");

      if (response.statusCode == 200) {
        final List data = response.data;
        // Map the StationResponseDTOs from backend to your StationModel
        _currentItinerary = data.map((json) => StationModel.fromJson(json)).toList();
        debugPrint("🛤️ Loaded ${_currentItinerary.length} stops for trip $rotationId");
      }
    } catch (e) {
      debugPrint("❌ Itinerary Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}