/**
 * 🚌 THE TRIP SCHEDULE MODEL:
 */
class DisplayInfoModel {
  final String? id;
  final String? lineNumber;
  final String? departureTime;
  final String? arrivalTime;
  final String? busPlate;
  final String? departureStation;
  final String? arrivalStation;
  final bool isCancelled;

  DisplayInfoModel({
    this.id,
    this.lineNumber,
    this.departureTime,
    this.arrivalTime,
    this.busPlate,
    this.departureStation,
    this.arrivalStation,
    this.isCancelled = false,
  });

  factory DisplayInfoModel.fromJson(Map<String, dynamic> json) {
    return DisplayInfoModel(
      id: json['id']?.toString(),
      lineNumber: json['lineNumber'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      busPlate: json['busPlate'],
      departureStation: json['departureStation'],
      arrivalStation: json['arrivalStation'],
      // 🚀 THE FIX: Checks all possible cancellation flags from your DTO and DB
      isCancelled: json['isCancelled'] == true ||
          json['cancelled'] == true ||
          json['rannul'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lineNumber': lineNumber,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'busPlate': busPlate,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'isCancelled': isCancelled,
    };
  }
}