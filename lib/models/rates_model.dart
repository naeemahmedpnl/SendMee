// lib/models/rates_model.dart
class Rates {
  final String id;
  final double baseFare;
  final double vehicleRate;
  final double adjustmentFare;

  Rates({
    required this.id,
    required this.baseFare,
    required this.vehicleRate,
    required this.adjustmentFare,
  });

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      id: json['_id'],
      baseFare: json['baseFare'].toDouble(),
      vehicleRate: json['vehicleRate'].toDouble(),
      adjustmentFare: json['adjustmentFare'].toDouble(),
    );
  }
}