// lib/core/constants/api_constants.dart

class ApiConstants {
  // Replace with your machine's IP address (e.g., 192.168.1.5)
  // Use 10.0.2.2 for Android Emulator to access localhost
  static const String baseUrl = "http://192.168.100.8:8080/api";

  // Auth Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";
  static const String guest = "$baseUrl/auth/guest";

  // Tracking & Trip Endpoints
  static const String liveTracking = "$baseUrl/tracking"; // + /{rotationId}/live
  static const String confirmTrip = "$baseUrl/trips"; // + /{rotationId}/confirm
  static const String stationTrips = "$baseUrl/trips/station"; // + /{stationId}

  // Map & User Endpoints
  static const String nearbyStations = "$baseUrl/map/stations/nearby";
  static const String updateUserLocation = "$baseUrl/users"; // + /{id}/location
  static const String updateLocation = "$baseUrl/auth/update-location";
}