// lib/data/repositories/map_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/station_model.dart';
import '../models/rotation_model.dart';

class MapRepository {
  final DioClient _client;

  MapRepository(this._client);

  /// Fetches stations within a specific radius of the user's location.
  Future<List<StationModel>> getNearbyStations(double lat, double lon) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.nearbyStations,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': 10.0, // Matches the 10km range we established
        },
      );

      if (response.data != null && response.data is List) {
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

  /// Fetches all active bus trips passing through a specific station.
  Future<List<RotationModel>> getTripsForStation(String stationId) async {
    try {
      final response = await _client.dio.get("${ApiConstants.stationTrips}/$stationId/trips");

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => RotationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ MapRepository (getTripsForStation) Error: $e");
      rethrow;
    }
  }

  /// Fetches the sequential itinerary (stops) for a specific trip.
  Future<List<StationModel>> getTripItinerary(String rotationId) async {
    try {
      final response = await _client.dio.get("${ApiConstants.stationTrips}/trips/$rotationId/itinerary");

      if (response.data != null && response.data is List) {
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