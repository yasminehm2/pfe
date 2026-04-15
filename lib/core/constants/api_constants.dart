class ApiConstants {
  static const String baseUrl = "http://192.168.100.8:8080/api";

  // Auth Endpoints (AuthController)
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/signup";
  static const String guest = "$baseUrl/auth/guest";
  static const String updateLocation = "$baseUrl/auth/update-location";

  // Station Endpoints (StationController)
  static const String nearbyStations = "$baseUrl/stations/nearby";
  static const String stationTrips = "$baseUrl/stations"; // Will use /$id/trips

  // Tracking Endpoints (TrackingController)
  static const String liveTracking = "$baseUrl/tracking"; // + /{rotationId}/live
  static const String confirmTrip = "$baseUrl/tracking"; // + /{rotationId}/confirm
}