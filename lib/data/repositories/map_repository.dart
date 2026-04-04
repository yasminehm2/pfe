// lib/data/repositories/map_repository.dart

import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/station_model.dart';

class MapRepository {
  final DioClient _client;

  MapRepository(this._client);

  /// Fetches stations within a 2km radius of the user's GPS position
  Future<List<StationModel>> getNearbyStations(double lat, double lon) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.nearbyStations,
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );

      // Maps the List<Station> from Spring Boot to List<StationModel> in Flutter
      return (response.data as List)
          .map((json) => StationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}