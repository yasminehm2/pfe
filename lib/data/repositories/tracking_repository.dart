// lib/data/repositories/tracking_repository.dart
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/live_tracking_model.dart';

class TrackingRepository {
  final DioClient _client;

  TrackingRepository(this._client);

  Future<LiveTrackingModel> getLiveUpdate(String rotationId, String stationId) async {
    final response = await _client.dio.get(
      "${ApiConstants.liveTracking}/$rotationId/live",
      queryParameters: {'stationId': stationId},
    );
    return LiveTrackingModel.fromJson(response.data);
  }
}