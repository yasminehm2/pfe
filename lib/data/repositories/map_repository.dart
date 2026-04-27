// lib/data/repositories/map_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/station_model.dart';
import '../models/displayInfo_model.dart';

/**
 * 🗺️ THE MAP REPOSITORY:
 * This class fetches all the spatial data (locations and routes).
 * It talks to the 'StationController' in your Spring Boot backend.
 */
class MapRepository {
  final DioClient _client;

  MapRepository(this._client);

  /// 📍 NEARBY SEARCH: "Show me what's around the user"
  /// Hits: GET /api/stations/nearby?lat=...&lon=...&radius=10.0
  Future<List<StationModel>> getNearbyStations(double lat, double lon) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.nearbyStations,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': 10.0, // We search in a 10km circle around the user.
        },
      );

      if (response.data != null && response.data is List) {
        // Turns the list of JSON stations into a list of 'StationModel' objects.
        return (response.data as List)
            .map((json) => StationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ MapRepository (getNearbyStations) Error: $e");
      rethrow;
    }
  }

  /// 🚌 STATION TRIPS: "What buses stop at this specific pin?"
  /// Hits: GET /api/stations/{id}/trips
  Future<List<DisplayInfoModel>> getTripsForStation(String stationId) async {
    try {
      // We build the URL dynamically by adding the stationId.
      final response = await _client.dio.get("${ApiConstants.stationTrips}/$stationId/trips");

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => DisplayInfoModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ MapRepository (getTripsForStation) Error: $e");
      rethrow;
    }
  }

  /// 🛤️ ITINERARY: "Draw the path for this bus trip"
  /// Hits: GET /api/stations/trips/{id}/itinerary
  Future<List<StationModel>> getTripItinerary(String rotationId) async {
    try {
      final response = await _client.dio.get("${ApiConstants.stationTrips}/trips/$rotationId/itinerary");

      if (response.data != null && response.data is List) {
        // Returns the list of stations in the correct order (Stop 1, Stop 2, etc.)
        return (response.data as List)
            .map((json) => StationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ MapRepository (getTripItinerary) Error: $e");
      rethrow;
    }
  }
}