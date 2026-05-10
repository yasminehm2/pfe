import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Used to print messages only in debug mode
import 'package:shared_preferences/shared_preferences.dart'; // 🚀 IMPORTED FOR JWT
import '../constants/api_constants.dart';

/**
 * 📡 THE "COMMUNICATIONS TOWER":
 * This class handles all the internet talking between Flutter and Spring Boot.
 * It uses 'Dio', which is a powerful library for making API requests.
 */
class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl, // Uses the IP address from your constants file

      // ⏳ PATIENCE SETTINGS:
      // We give the server 40 seconds to connect/respond.
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
      sendTimeout: const Duration(seconds: 40),

      responseType: ResponseType.json, // We expect data in JSON format
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {

    // 🕵️ THE INTERCEPTOR (The Spy):
    // This "spies" on every request to help you debug and attaches the JWT token.
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async { // 🚀 MADE ASYNC TO READ STORAGE

        // 🚀 JWT INJECTION: Grab the token from storage and attach it to the header
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Prints "🚀 SENDING REQUEST" in your console when you click a button.
        debugPrint("🚀 SENDING REQUEST: [${options.method}] ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Prints "✅ RESPONSE RECEIVED" if the Spring Boot server answers.
        debugPrint("✅ RESPONSE RECEIVED: [${response.statusCode}]");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Prints "❌ API ERROR" if something breaks (like wrong IP or server off).
        debugPrint("❌ API ERROR: ${e.type} | ${e.message}");
        return handler.next(e);
      },
    ));

    // Shows the full data (JSON body) in the console while you are developing.
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // A getter to use this configured "messenger" in other files.
  Dio get dio => _dio;

  /**
   * 🛠️ THE TRANSLATOR (Error Handler):
   * Converts technical computer errors into human-friendly messages.
   */
  String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return "Server is taking too long to respond. Please check your Spring Boot app.";

      case DioExceptionType.connectionError:
        return "Cannot reach the server. Ensure your backend is running at ${ApiConstants.baseUrl}";

      case DioExceptionType.badResponse:
      // If Spring Boot sends a specific error (like "Email already exists"), show it.
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return "Server error: ${error.response?.statusCode}";

      default:
        return "An unexpected error occurred. Please try again.";
    }
  }
}