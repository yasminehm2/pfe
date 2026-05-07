// lib/data/repositories/tracking_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/rotation_model.dart';

/**
 * 📡 THE TRACKING REPOSITORY:
 * This class handles the real-time communication for a moving bus.
 * It talks to the 'TrackingController' in your Spring Boot backend.
 */
class RotationRepository {
  final DioClient _client;

  RotationRepository(this._client);

  /// ✅ THE HANDSHAKE: "I am now tracking this bus"
  /// Hits: POST /api/tracking/{rotationId}/confirm?userId={userId}
  Future<bool> confirmTripTracking(String rotationId, String userId) async {
    try {
      await _client.dio.post(
        "${ApiConstants.confirmTrip}/$rotationId/confirm",
        queryParameters: {'userId': userId},
      );
      // If the server says "OK", we return true.
      return true;
    } catch (e) {
      debugPrint("❌ TrackingRepository (confirmTrip) Error: $e");
      return false; // If the connection fails, we return false.
    }
  }

  /// 🛰️ THE LIVE FEED: "Give me the latest GPS and ETA"
  /// Hits: GET /api/tracking/{rotationId}/live?stationId={stationId}
  /// This is called repeatedly (polling) to move the bus on the map.
  Future<RotationModel> getLiveUpdate(String rotationId, String stationId) async {
    try {
      final response = await _client.dio.get(
        "${ApiConstants.liveTracking}/$rotationId/live",
        queryParameters: {'stationId': stationId},
      );

      // Converts the live JSON data into a 'LiveTrackingModel' object.
      return RotationModel.fromJson(response.data);
    } catch (e) {
      debugPrint("❌ TrackingRepository (getLiveUpdate) Error: $e");
      // We 'rethrow' so the UI knows if the GPS signal was lost.
      rethrow;
    }
  }
}