class ApiConstants {
  // 🏠 THE HOME BASE:
  // This is the IP address of your computer running the Spring Boot backend.
  // 10.26.12.7 is your local network address, and 8080 is the default Spring port.
  static const String baseUrl = "http://192.168.100.8:8080/api";
  // Quick lookup to prevent unnecessary GPS requests
  static const String checkEmail = "$baseUrl/users/check-email";
  static const String login = "$baseUrl/users/login";
  static const String signup = "$baseUrl/users/signup";
  static const String guest = "$baseUrl/users/guest";
  static const String updateUserLocation = "$baseUrl/users/update-location";

  // 📍 MAP & STATIONS:
  // These link to your StationController.java.

  // Used for the "Show stops within 2km" feature.
  static const String nearbyStations = "$baseUrl/stations/nearby";

  // Used when you tap a stop to see the timetable.
  // You will add the station ID to the end of this in your code.
  static const String stationTrips = "$baseUrl/stations";

  // 📡 LIVE TRACKING:
  // These link to your TrackingController.java.

  // The "Polling" address to get the moving bus coordinates.
  static const String liveTracking = "$baseUrl/tracking";

  // Tells the server: "I have officially started following this bus."
  static const String confirmTrip = "$baseUrl/tracking";

}