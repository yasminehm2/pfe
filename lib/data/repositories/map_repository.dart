// lib/data/repositories/map_repository.dart

import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/station_model.dart';

class MapRepository {
  final DioClient _client;

  MapRepository(this._client);

  /// Fetches stations within a larger radius to ensure they appear on the map.
  Future<List<StationModel>> getNearbyStations(double lat, double lon) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.nearbyStations,
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'radius': 10.0, // 🚀 Increased range to 10km to match backend changes
        },
      );

      // Maps the List<Station> from Spring Boot to List<StationModel> in Flutter
      if (response.data != null && response.data is List) {
        return (response.data as List)
            .map((json) => StationModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      // Log the error to see if it's a 404, 500, or a parsing error
      print("Repository Error: $e");
      rethrow;
    }
  }

}