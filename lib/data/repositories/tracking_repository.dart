// lib/data/repositories/tracking_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/live_tracking_model.dart';

class TrackingRepository {
  final DioClient _client;

  TrackingRepository(this._client);

  /// Activates the trip tracking session in the backend for the current user.
  Future<bool> confirmTripTracking(String rotationId, String userId) async {
    try {
      await _client.dio.post(
        "${ApiConstants.confirmTrip}/$rotationId/confirm",
        queryParameters: {'userId': userId},
      );
      return true;
    } catch (e) {
      debugPrint("❌ TrackingRepository (confirmTrip) Error: $e");
      return false;
    }
  }

  /// Polls the backend for the dynamic ETA and live GPS coordinates.
  Future<LiveTrackingModel> getLiveUpdate(String rotationId, String stationId) async {
    try {
      final response = await _client.dio.get(
        "${ApiConstants.liveTracking}/$rotationId/live",
        queryParameters: {'stationId': stationId},
      );
      return LiveTrackingModel.fromJson(response.data);
    } catch (e) {
      debugPrint("❌ TrackingRepository (getLiveUpdate) Error: $e");
      rethrow;
    }
  }
}