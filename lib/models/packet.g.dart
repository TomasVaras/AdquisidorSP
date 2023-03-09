// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PacketAdapter extends TypeAdapter<Packet> {
  @override
  final int typeId = 0;

  @override
  Packet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Packet(
      guidNumber: fields[0] as String,
      date: fields[1] as DateTime,
      deviceName: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      dataPacketQuantity: fields[5] as int,
      dataPacketNumber: fields[6] as int,
      dataRegisterQuantity: fields[7] as int,
      timestamps: (fields[8] as List).cast<DateTime>(),
      pressures: (fields[9] as List).cast<double>(),
      flows: (fields[10] as List).cast<double>(),
      temperatures: (fields[11] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Packet obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.guidNumber)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.deviceName)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.dataPacketQuantity)
      ..writeByte(6)
      ..write(obj.dataPacketNumber)
      ..writeByte(7)
      ..write(obj.dataRegisterQuantity)
      ..writeByte(8)
      ..write(obj.timestamps)
      ..writeByte(9)
      ..write(obj.pressures)
      ..writeByte(10)
      ..write(obj.flows)
      ..writeByte(11)
      ..write(obj.temperatures);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PacketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
