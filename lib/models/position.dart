import 'package:hive/hive.dart';

import 'package:hive/hive.dart';

part 'position.g.dart';

@HiveType(typeId: 1)
class Position extends HiveObject {
  @HiveField(0)
  String deviceName;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  double altitude;

  @HiveField(5)
  double accuracy;

  @HiveField(6)
  double distance;

  @HiveField(7)
  bool inMovement;

  Map<String, dynamic> toJson() => {
        "deviceName": deviceName,
        "timestamp": timestamp.toIso8601String(),
        "latitude": latitude,
        "longitude": longitude,
        "altitude": altitude,
        "accuracy": accuracy,
        "distance": distance,
        "inMovement": inMovement
      };

  Position(
      {required this.deviceName,
      required this.timestamp,
      required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.accuracy,
      required this.distance,
      required this.inMovement});
}
