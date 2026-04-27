/**
 * 🛰️ THE LIVE UPDATE MODEL:
 * This class is the Flutter version of the 'LiveTrackingDTO' from your Java backend.
 * It holds the real-time "heartbeat" of the bus.
 */
class LiveTrackingModel {
  final String? rotationId;   // The trip ID (optional, might be null)
  final String? lineNumber;   // The bus number (e.g., "Line 10")
  final String? destination;  // Final stop name

  // 📍 GPS POSITION:
  // Stored as doubles so Google Maps can use them immediately.
  final double vehicleLat;
  final double vehicleLon;

  final double etaMinutes;    // How many minutes until arrival
  final String status;        // "moving", "stopped", etc.
  final bool arrivalAlert;    // Becomes true when the bus is < 100m away

  // THE CONSTRUCTOR:
  // Creates the object in your code.
  LiveTrackingModel({
    this.rotationId,
    this.lineNumber,
    this.destination,
    required this.vehicleLat,
    required this.vehicleLon,
    required this.etaMinutes,
    required this.status,
    required this.arrivalAlert,
  });

  /**
   * 🏗️ THE FACTORY (The Translator):
   * This is the most important part!
   * It takes a raw Map (JSON) from the Spring Boot API and
   * "builds" a LiveTrackingModel object out of it.
   */
  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    return LiveTrackingModel(
      rotationId: json['rotationId'],
      lineNumber: json['lineNumber'],
      destination: json['destination'],

      // We use 'as num' and '.toDouble()' to safely convert
      // numbers, even if the API sends an integer by mistake.
      vehicleLat: (json['vehicleLat'] as num).toDouble(),
      vehicleLon: (json['vehicleLon'] as num).toDouble(),
      etaMinutes: (json['etaMinutes'] as num).toDouble(),

      // '??' provides a default value if the data is missing.
      status: json['status'] ?? 'unknown',
      arrivalAlert: json['arrivalAlert'] ?? false,
    );
  }
}