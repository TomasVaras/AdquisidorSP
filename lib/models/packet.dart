import 'package:hive/hive.dart';

part 'packet.g.dart';

@HiveType(typeId: 0)
class Packet extends HiveObject {
  @HiveField(0)
  String guidNumber;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String deviceName;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  @HiveField(5)
  int dataPacketQuantity;

  @HiveField(6)
  int dataPacketNumber;

  @HiveField(7)
  int dataRegisterQuantity;

  @HiveField(8)
  List<DateTime> timestamps;

  @HiveField(9)
  List<double> pressures;

  @HiveField(10)
  List<double> flows;

  @HiveField(11)
  List<double> temperatures;

  Map<String, dynamic> toJson() => {
        "guidNumber": guidNumber,
        "date": date.toIso8601String(),
        "deviceName": deviceName,
        "latitudeDataLogger": latitude.toString(),
        "longitudeDataLogger": longitude.toString(),
        "dataPacketQuantity": dataPacketQuantity,
        "dataPacketNumber": dataPacketNumber,
        "dataRegisterQuantity": dataRegisterQuantity,
        "timeStamps": timestamps.map((e) => e.toIso8601String()).toList(),
        "presures": pressures.map((e) => e.round()).toList(),
        "flows": flows.map((e) => e.round()).toList(),
        "temperatures": temperatures.map((e) => e.round()).toList()
      };

  Packet(
      {required this.guidNumber,
      required this.date,
      required this.deviceName,
      required this.latitude,
      required this.longitude,
      required this.dataPacketQuantity,
      required this.dataPacketNumber,
      required this.dataRegisterQuantity,
      required this.timestamps,
      required this.pressures,
      required this.flows,
      required this.temperatures});
}
