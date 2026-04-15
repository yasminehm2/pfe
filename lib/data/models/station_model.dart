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
      nameAr: json['nameAr'] ?? '', // 🚀 Match the DTO key
      nameFr: json['nameFr'] ?? '', // 🚀 Match the DTO key
      latitude: _parseCoordinate(json['latitude']),
      longitude: _parseCoordinate(json['longitude']),
    );
  }

  static double _parseCoordinate(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}