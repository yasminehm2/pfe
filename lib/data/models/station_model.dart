/**
 * 📍 THE STATION BLUEPRINT:
 * Represents a physical bus stop with timing and tracking data.
 */
class StationModel {
  final String id;
  final String nameAr;
  final String nameFr;
  final double latitude;
  final double longitude;

  // 🚀 NEW FIELDS FOR LIVE TRACKING & TIMELINE
  final int? minutesFromStartStation; // 👈 This fixes the red error
  final int? liveEtaMinutes;          // Dynamic countdown (e.g., 5 min)
  final bool hasPassed;               // Status flag for the itinerary list

  StationModel({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.latitude,
    required this.longitude,
    this.minutesFromStartStation,
    this.liveEtaMinutes,
    this.hasPassed = false,
  });

  /**
   * 🏗️ THE FACTORY (JSON to Dart):
   * This builds the object from the Spring Boot API response.
   */
  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['nameAr'] ?? '',
      nameFr: json['nameFr'] ?? '',
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),

      // 🚀 THE FIX: Check all possible JSON keys sent by the backend
      minutesFromStartStation: json['minutesFromStartStation'] ?? json['minutes_from_start'],

      liveEtaMinutes: json['liveEtaMinutes'],
      hasPassed: json['hasPassed'] ?? false,
    );
  }

  /**
   * 🛠️ THE DATA CLEANER:
   * Ensures coordinates are always valid doubles.
   */
  static double _parseCoordinate(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  /**
   * 💾 THE SAVER:
   * Used if you ever need to store an itinerary locally.
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameFr': nameFr,
      'latitude': latitude,
      'longitude': longitude,
      'minutesFromStartStation': minutesFromStartStation,
      'liveEtaMinutes': liveEtaMinutes,
      'hasPassed': hasPassed,
    };
  }
}