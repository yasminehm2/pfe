class RotationModel {
  final String? id;
  final String? lineNumber;
  final String? departureTime;
  final String? arrivalTime;
  final String? busPlate;
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
}