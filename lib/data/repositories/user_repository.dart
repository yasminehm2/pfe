import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

/**
 * 💼 THE AUTH REPOSITORY:
 * This class organizes all the "Identity" actions.
 * Updated to match the UserDTO architecture on the Spring Boot backend.
 */
class UserRepository {
  final DioClient _client;

  UserRepository(this._client);

  /// 📝 SIGNUP: "Create a new profile"
  /// Sends structured data that matches UserDTO.java
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
          'lat': lat ?? 0.0,
          'lon': lon ?? 0.0,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError("Signup", e);
      rethrow;
    } catch (e) {
      debugPrint("Unexpected Signup Error: $e");
      rethrow;
    }
  }

  /// 🔑 LOGIN: "Verify existing account"
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

  /// 🔎 QUICK CHECK: "Is this email already taken?"
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.checkEmail,
        queryParameters: {'email': email},
      );
      return response.data['exists'] ?? false;
    } on DioException catch (e) {
      _handleDioError("Check Email", e);
      return false;
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
  /// 🚀 UPDATED: Uses POST to /api/auth/update-location as per new backend controller.
  Future<void> updateUserLocation({
    required String email,
    required double lat,
    required double lon,
  }) async {
    try {
      await _client.dio.post(
        ApiConstants.updateUserLocation,
        data: {
          "email": email, // Backend uses email to find the user in updateUserCoordinates
          "lat": lat,
          "lon": lon,
        },
      );
      debugPrint("✅ Database updated with coordinates for: $email");
    } on DioException catch (e) {
      _handleDioError("Update Location", e);
    } catch (e) {
      debugPrint("Unexpected Location Update Error: $e");
    }
  }

  /**
   * 🛠️ ERROR LOGGER:
   * Helps debug connection issues with the Spring Boot server.
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