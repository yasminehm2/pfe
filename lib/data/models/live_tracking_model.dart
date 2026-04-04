// lib/data/models/live_tracking_model.dart
class LiveTrackingModel {
  final String rotationId;
  final double vehicleLat;
  final double vehicleLon;
  final double etaMinutes;
  final String status;
  final bool arrivalAlert;

  LiveTrackingModel({
    required this.rotationId,
    required this.vehicleLat,
    required this.vehicleLon,
    required this.etaMinutes,
    required this.status,
    required this.arrivalAlert,
  });

  factory LiveTrackingModel.fromJson(Map<String, dynamic> json) {
    return LiveTrackingModel(
      rotationId: json['rotationId'],
      vehicleLat: json['vehicleLat'],
      vehicleLon: json['vehicleLon'],
      etaMinutes: (json['etaMinutes'] as num).toDouble(),
      status: json['status'] ?? 'moving', // moving/stopped/visible
      arrivalAlert: json['arrivalAlert'] ?? false, // Trigger if < 1 min
    );
  }
}