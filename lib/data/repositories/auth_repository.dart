import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as _dio;

import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  /// Registers a new user in the database with coordinates
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
          // 💡 TIP: Si ton backend accepte les valeurs nulles,
          // enlève le "?? 0.0" pour éviter de placer l'utilisateur au milieu de l'océan.
          'lat': lat ?? 0.0,
          'lon': lon ?? 0.0,
        },
      );

      // Dio décode automatiquement le JSON en Map<String, dynamic>
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError("Signup", e);
      rethrow;
    } catch (e) {
      debugPrint("Unexpected Signup Error: $e");
      rethrow;
    }
  }

  /// Authenticates an existing user
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

  /// Provides temporary access
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

  // Inside your AuthRepository class
  // Replace your existing updateUserLocation with this:
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

  /// Helper method to log detailed Dio errors in development
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
