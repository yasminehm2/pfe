// lib/data/models/rotation_model.dart
class RotationModel {
  final String? id; // Display record ID
  final String? lineNumber; // denumli (e.g. L1)
  final String? departureTime; // depart column
  final String? arrivalTime; // arrivee column
  final String? busPlate; // vehicule
  final String? departureStation;
  final String? arrivalStation;

  RotationModel({
    this.id,
    this.lineNumber,
    this.departureTime,
    this.arrivalTime,
    this.busPlate,
    this.departureStation,
    this.arrivalStation,
  });

  factory RotationModel.fromJson(Map<String, dynamic> json) {
    return RotationModel(
      id: json['id']?.toString(),
      lineNumber: json['lineNumber'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      busPlate: json['busPlate'],
      departureStation: json['departureStation'],
      arrivalStation: json['arrivalStation'],
    );
  }

  // 🚀 ADDED: Converts the object to JSON for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lineNumber': lineNumber,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'busPlate': busPlate,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
    };
  }
}