import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

/**
 * 💼 THE AUTH REPOSITORY:
 * This class organizes all the "Identity" actions.
 * It sits between the UI and the Network layer.
 */
class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  /// 📝 SIGNUP: "Create a new profile in Sfax"
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    double? lat,
    double? lon,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          // Defaults to 0.0 if the user hasn't allowed GPS yet.
          'lat': lat ?? 0.0,
          'lon': lon ?? 0.0,
        },
      );

      // Converts the JSON reply from Spring Boot into a UserModel.
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError("Signup", e);
      rethrow; // Passes the error up so the UI can show a snackbar.
    } catch (e) {
      debugPrint("Unexpected Signup Error: $e");
      rethrow;
    }
  }

  /// 🔑 LOGIN: "Verify my existing account"
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError("Login", e);
      rethrow;
    } catch (e) {
      debugPrint("Unexpected Login Error: $e");
      rethrow;
    }
  }

  /// 🚪 GUEST ACCESS: "Let me in quickly"
  Future<UserModel> enterAsGuest() async {
    try {
      final response = await _client.dio.post(ApiConstants.guest);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError("Guest Access", e);
      rethrow;
    } catch (e) {
      debugPrint("Unexpected Guest Access Error: $e");
      rethrow;
    }
  }

  /// 📍 SYNC LOCATION: "Keep the database updated with my GPS"
  /// Uses a PATCH request to specifically update only the coordinates.
  Future<void> updateUserLocation({
    required String userId,
    required double lat,
    required double lon,
  }) async {
    try {
      await _client.dio.patch(
        "${ApiConstants.updateUserLocation}/$userId/location",
        data: {
          "lat": lat,
          "lon": lon,
        },
      );
      debugPrint("✅ Database updated with coordinates.");
    } on DioException catch (e) {
      _handleDioError("Update Location", e);
    }
  }

  /**
   * 🛠️ ERROR LOGGER:
   * A helper method to print exactly what went wrong in your console.
   * Very helpful for finding out if your Spring Boot server is down!
   */
  void _handleDioError(String action, DioException e) {
    debugPrint("---------- Dio Error during $action ----------");
    debugPrint("Message: ${e.message}");
    if (e.response != null) {
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Response Data: ${e.response?.data}");
    }
    debugPrint("-----------------------------------------------");
  }
}