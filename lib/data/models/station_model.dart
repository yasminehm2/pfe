class StationModel {
  final String id;
  final String nameAr;
  final String nameFr;
  final double latitude;
  final double longitude;

  StationModel({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.latitude,
    required this.longitude,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id']?.toString() ?? '',
      // Map 'delstat' from Java to 'nameAr' in Flutter
      nameAr: json['delstat'] ?? '',
      // Map 'delstatfr' from Java to 'nameFr' in Flutter
      nameFr: json['delstatfr'] ?? '',
      // Robust coordinate parsing
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
    );
  }

  // Helper to handle both String and Double types from JSON safely
  static double _parseCoordinate(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}