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
  Future<void> updateUserLocation({
    required String email,
    required double lat,
    required double lon,
  }) async {
    try {
      // 🚀 Use the constant from your ApiConstants file
      final url = Uri.parse(ApiConstants.updateLocation);

      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "lat": lat,
          "lon": lon,
        }),
      ).timeout(const Duration(seconds: 10)); // 🚀 Add this to prevent infinite loading

      if (response.statusCode == 200) {
        print("✅ MySQL Database updated with your specific coordinates.");
      } else {
        print("❌ Server error: ${response.statusCode}");
      }
    } catch (e) {
      // This catches connection errors (like if Spring Boot is off)
      print("❌ Connection failed: $e");
    }
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
