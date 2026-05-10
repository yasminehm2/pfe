// lib/data/repositories/station_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/station_model.dart';

/**
 * 📍 THE STATION REPOSITORY:
 * Handles geographical data and physical stop locations.
 * Talks to StationController.java
 */
class StationRepository {
  final DioClient _client;

  StationRepository(this._client);

  /// 📍 NEARBY SEARCH: "Show me what's around the user"
  /// Hits: GET /api/stations/nearby
  Future<List<StationModel>> getNearbyStations(double lat, double lon) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.nearbyStations,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': 10.0,
        },
      );

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => StationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ StationRepository (getNearbyStations) Error: $e");
      rethrow;
    }
  }

  /// 🛤️ ITINERARY: "Fetch the ordered list of stops for a path"
  /// Hits: GET /api/stations/trips/{id}/itinerary
  Future<List<StationModel>> getTripItinerary(String rotationId) async {
    try {
      final response = await _client.dio.get(
          "${ApiConstants.stationTrips}/trips/$rotationId/itinerary"
      );

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => StationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ StationRepository (getTripItinerary) Error: $e");
      rethrow;
    }
  }
}