import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/station_model.dart';
import '../../data/repositories/map_repository.dart';

class MapProvider extends ChangeNotifier {
  final MapRepository _repository;

  MapProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Default center: Sfax, Tunisia
  LatLng _currentViewCenter = const LatLng(34.74, 10.76);
  LatLng get currentViewCenter => _currentViewCenter;

  List<Marker> _stationMarkers = [];
  List<Marker> get allMarkers => _stationMarkers;

  /// Updates the center and fetches new stations
  void updateCenter(LatLng newCenter) {
    _currentViewCenter = newCenter;
    fetchNearbyStations(newCenter.latitude, newCenter.longitude);
  }

  /// Fetches stations and builds Bilingual Markers
  Future<void> fetchNearbyStations(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();

    try {
      final stations = await _repository.getNearbyStations(lat, lon);

      _stationMarkers = stations.map((station) {
        return Marker(
          point: LatLng(station.latitude, station.longitude),
          // Increased width/height to fit the text labels above the icon
          width: 120,
          height: 80,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Bilingual Label Container ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Arabic Name (Top)
                    Text(
                      station.nameAr,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    // French Name (Bottom)
                    Text(
                      station.nameFr,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // --- The Icon ---
              const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 30,
              ),
            ],
          ),
        );
      }).toList();

      debugPrint("Loaded ${stations.length} bilingual markers.");
    } catch (e) {
      debugPrint("MapProvider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}