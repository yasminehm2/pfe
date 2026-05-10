// lib/logic/providers/station_provider.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../data/models/station_model.dart';
import '../../data/repositories/station_repository.dart';

class StationProvider extends ChangeNotifier {
  final StationRepository _repository;

  StationProvider(this._repository);

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

  LatLng _currentViewCenter = const LatLng(34.727, 10.718);
  LatLng get currentViewCenter => _currentViewCenter;

  Function(String, String)? onStationSelected;

  void updateCenter(LatLng newCenter) {
    _currentViewCenter = newCenter;
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
      debugPrint("❌ Station Sync Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoadAlignedPath(List<StationModel> stations) async {
    if (stations.length < 2) return;
    final String coords = stations.map((s) => "${s.longitude},${s.latitude}").join(';');
    final url = 'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordsList = data['routes'][0]['geometry']['coordinates'];
        _routePoints = coordsList.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();
      }
    } catch (e) {
      _routePoints = stations.map((s) => LatLng(s.latitude, s.longitude)).toList();
    }
    notifyListeners();
  }

  void resetMap() {
    _routePoints = [];
    _stationMarkers = [];
    _allStations = [];
    notifyListeners();
  }

  Widget _buildStationLabel(String ar, String fr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
      ),
      child: Column(
        children: [
          Text(ar, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          Text(fr, style: const TextStyle(fontSize: 8, color: Colors.blueAccent)),
        ],
      ),
    );
  }
}