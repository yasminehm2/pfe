import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../constants/api_constants.dart';

class DioClient {
  final Dio _dio;

  DioClient()
      : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      // 🚀 INCREASED TIMEOUTS: 5s is too short for some GPS/DB lookups
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    // Advanced Logging Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint("🚀 SENDING REQUEST: [${options.method}] ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("✅ RESPONSE RECEIVED: [${response.statusCode}]");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("❌ API ERROR: ${e.type} | ${e.message}");
        return handler.next(e);
      },
    ));

    // Optional: Keep the standard LogInterceptor for full body debugging
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Dio get dio => _dio;

  // Optimized Error Handling
  String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return "Server is taking too long to respond. Please check your Spring Boot app.";

      case DioExceptionType.connectionError:
        return "Cannot reach the server. Ensure your backend is running at ${ApiConstants.baseUrl}";

      case DioExceptionType.badResponse:
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