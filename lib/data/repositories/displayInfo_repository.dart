// lib/data/repositories/display_info_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/displayInfo_model.dart';

/**
 * 🚌 THE DISPLAY INFO REPOSITORY:
 * Handles trip schedules and line information.
 * Talks to StationController.java / DisplayInfoService.java
 */
class DisplayInfoRepository {
  final DioClient _client;

  DisplayInfoRepository(this._client);

  /// 🚌 STATION TRIPS: "What buses stop at this specific pin?"
  /// Hits: GET /api/stations/{id}/trips
  Future<List<DisplayInfoModel>> getTripsForStation(String stationId) async {
    try {
      final response = await _client.dio.get(
        "${ApiConstants.stationTrips}/$stationId/trips"
      );

      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => DisplayInfoModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ DisplayInfoRepository (getTripsForStation) Error: $e");
      rethrow;
    }
  }
}