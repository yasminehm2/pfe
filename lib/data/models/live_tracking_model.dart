class LiveTrackingModel {
  final String? rotationId;
  final String? lineNumber;
  final String? destination;
  final double vehicleLat; // Matches LiveTrackingDTO.vehicleLat
  final double vehicleLon; // Matches LiveTrackingDTO.vehicleLon
  final double etaMinutes;
  final String status;
  final bool arrivalAlert;

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

  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    return LiveTrackingModel(
      rotationId: json['rotationId'],
      lineNumber: json['lineNumber'],
      destination: json['destination'],
      vehicleLat: (json['vehicleLat'] as num).toDouble(),
      vehicleLon: (json['vehicleLon'] as num).toDouble(),
      etaMinutes: (json['etaMinutes'] as num).toDouble(),
      status: json['status'] ?? 'unknown',
      arrivalAlert: json['arrivalAlert'] ?? false,
    );
  }
}