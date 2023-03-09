import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sp_adquisidor_app/models/packet.dart';
import 'package:sp_adquisidor_app/models/position.dart' as ps;
import 'package:uuid/uuid.dart' as uuid_gen;
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:async/async.dart';

class DataAndPositionAcquisitionCard extends StatefulWidget {
  const DataAndPositionAcquisitionCard({super.key});

  @override
  State<DataAndPositionAcquisitionCard> createState() =>
      _DataAndPositionAcquisitionCardState();
}

class _DataAndPositionAcquisitionCardState
    extends State<DataAndPositionAcquisitionCard> {
  final Box _acqBox = Hive.box<Packet>('acquisitionBox');
  final Box _posBox = Hive.box<ps.Position>('positionBox');
  final uuid = const uuid_gen.Uuid();
  final _ble = FlutterReactiveBle();
  Timer? _bleTimer;
  final Duration _bleStartScanInterval = const Duration(seconds: 10);
  final Duration _restartableTimerDuration = const Duration(minutes: 5);
  //metros
  String? message;
  //bool _isMoving = false;
  double? _distance;
  final ValueNotifier<bool> _isMoving = ValueNotifier<bool>(true);
  StreamSubscription<Position>? _positionStream;
  final LocationSettings _locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 25,
    //timeLimit: ,
    intervalDuration: const Duration(seconds: 1),
    foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'adquisidor',
        notificationText: 'background',
        enableWakeLock: true),
  );
  Position? _lastPosition;
  final List<dynamic> _acquisitions = [];
  dynamic? _lastAcq;

  @override
  void initState() {
    super.initState();

    _isMoving.addListener(() {
      if (_isMoving.value == false) {
        print('detenido');
        //start data fetching
        _saveGeoPosition(
          ps.Position(
              deviceName: 'zebra',
              timestamp: DateTime.now(),
              latitude: _lastPosition!.latitude,
              longitude: _lastPosition!.longitude,
              altitude: _lastPosition!.altitude,
              accuracy: 0.toDouble(), //_thresholdDistanceLimit.toDouble(),
              distance: 0,
              inMovement: _isMoving.value),
        );

        _startBluetoothScanAndDataAcq();
        //_startBluetoothScanAndDataAcq();
      } else {
        print('movimiento');
        //stop data fetching
        _bleTimer?.cancel();
        if (_acquisitions.isNotEmpty) {
          List<List<dynamic>> acquisitionsChunks;

          List<Packet> packetList;
          var id = uuid.v4();
          //create chunks
          acquisitionsChunks = _chunkAcquisitions(10, _acquisitions);

          print(acquisitionsChunks);

          DateTime sendDate = DateTime.now();
          //create packets
          packetList = _createPacketList(acquisitionsChunks, id, sendDate);

          print(packetList);

          _savePacketList(packetList);

          _acquisitions.clear();
        }
      }
    });
  }

  void _saveGeoPosition(ps.Position position) {
    _posBox.add(position);
  }

  void _startPositionFetching() async {
    RestartableTimer timer = RestartableTimer(_restartableTimerDuration, () {
      _isMoving.value = false;
    });
    _lastPosition = await Geolocator.getCurrentPosition();

    _positionStream =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((Position position) {
      _isMoving.value = true;
      timer.reset();
      _distance = Geolocator.distanceBetween(_lastPosition!.latitude,
          _lastPosition!.longitude, position.latitude, position.longitude);

      _lastPosition = position;

      _saveGeoPosition(
        ps.Position(
            deviceName: 'zebra',
            timestamp: DateTime.now(),
            latitude: _lastPosition!.latitude,
            longitude: _lastPosition!.longitude,
            altitude: _lastPosition!.altitude,
            accuracy: 0.toDouble(),
            distance: _distance!,
            inMovement: _isMoving.value),
      );

      print(
          '${position.latitude.toString()}, ${position.longitude.toString()}, $_distance, $_isMoving');
    });
  }

  dynamic _byteSequenceToData(DiscoveredDevice device) {
    print(device.manufacturerData);
    /*Uint8List byteSequence = device.manufacturerData.sublist(2, 6);
    print(byteSequence);
    ByteData byteData = ByteData.view(byteSequence.buffer);*/
    Uint8List byteSequence = device.manufacturerData.sublist(2, 6);

    final ByteData byteData = byteSequence.buffer.asByteData();
    final List<double> floatList = [
      for (var offset = 0;
          offset < device.manufacturerData.sublist(2, 6).length;
          offset += 4)
        byteData.getFloat32(offset, Endian.little)
    ];
    //double value = byteData.getFloat32(0, Endian.big);

    _lastAcq = floatList[0];

    setState(() {});

    return {"value": floatList[0], "timestamp": DateTime.now()};
  }

  List<List<dynamic>> _chunkAcquisitions(
      int every, List<dynamic> acquisitions) {
    List<List<dynamic>> acquisitionsChunks = [];
    for (var i = 0; i < acquisitions.length; i += every) {
      var end = min(i + every, acquisitions.length);
      acquisitionsChunks.add(acquisitions.sublist(i, end));
    }
    return acquisitionsChunks;
  }

  List<Packet> _createPacketList(
      List<List<dynamic>> acquisitionsChunks, String batchId, DateTime date) {
    List<Packet> packetList = [];
    for (var i = 0; i < acquisitionsChunks.length; i++) {
      var packet = Packet(
        guidNumber: batchId,
        date: date,
        deviceName: 'zebra',
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        dataPacketQuantity: acquisitionsChunks.length,
        dataPacketNumber: i + 1,
        dataRegisterQuantity: acquisitionsChunks[i].length,
        timestamps: acquisitionsChunks[i]
            .map((e) => e['timestamp'])
            .toList()
            .cast<DateTime>(),
        pressures: acquisitionsChunks[i]
            .map((e) => e['value'])
            .toList()
            .cast<double>(),
        flows: acquisitionsChunks[i]
            .map((e) => e['value'])
            .toList()
            .cast<double>(),
        temperatures: acquisitionsChunks[i]
            .map((e) => e['value'])
            .toList()
            .cast<double>(),
      );
      packetList.add(packet);
    }
    return packetList;
  }

  void _savePacketList(List<Packet> packetList) {
    _acqBox.addAll(packetList);
  }

  void _startBluetoothScanAndDataAcq() {
    DiscoveredDevice? device;
    List<DiscoveredDevice> devices;
    _bleTimer = Timer.periodic(
      _bleStartScanInterval,
      (timer) async {
        FlutterLogs.logInfo("acquisition", "state", "inicio");
        devices = await _ble
            .scanForDevices(withServices: [], scanMode: ScanMode.lowPower)
            .where((event) =>
                event.id == '94:B5:55:F8:1F:22' /*'7C:9E:BD:49:4E:FA'*/)
            .toList();

        devices.isNotEmpty ? device = devices.first : device = device;

        if (device != null) {
          _acquisitions.add(_byteSequenceToData(device!));
        } else {
          //log
          FlutterLogs.logWarn("acquisition", "state", "device not found");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    print('inicio');
                    _startPositionFetching();
                  },
                  child: const Text('inicio'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('detenido');
                    _positionStream!.cancel();
                  },
                  child: const Text('detener'),
                ),
                ElevatedButton(
                    onPressed: () {
                      _bleTimer?.cancel();
                      _isMoving.value = true;
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Icon(Icons.bluetooth)),
                ValueListenableBuilder(
                  valueListenable: _isMoving,
                  builder: (context, value, child) {
                    if (value) {
                      return const Text('...movimiento');
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ],
            ),
            Text(_lastAcq.toString()),
          ],
        ),
      ),
    );
  }
}
