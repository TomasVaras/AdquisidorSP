import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sp_adquisidor_app/models/packet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../models/position.dart';

class CheckAndSavePacketsCard extends StatefulWidget {
  const CheckAndSavePacketsCard({super.key});

  @override
  State<CheckAndSavePacketsCard> createState() =>
      _CheckAndSavePacketsCardState();
}

class _CheckAndSavePacketsCardState extends State<CheckAndSavePacketsCard> {
  final Box<Packet> _acqBox = Hive.box<Packet>('acquisitionBox');
  final Box<Position> _posBox = Hive.box<Position>('positionBox');
  final Duration _uploadInterval = const Duration(seconds: 10);
  final String _url = 'https://sp-webapi-wellservice.azurewebsites.net';

  Future<http.Response> _uploadSavedRegister(
      {required register, required uri}) {
    return http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'ApiKey': 'zBg3GanIzacfAicCKrpFXPcUl'
        },
        body: register);
  }

  void _periodicTryUpload({required Box box, required uri}) {
    Timer.periodic(_uploadInterval, (timer) async {
      final conn = await Connectivity().checkConnectivity();
      if (conn == ConnectivityResult.mobile ||
          conn == ConnectivityResult.wifi) {
        //enviar adquisciones
        if (box.isNotEmpty) {
          final values = box.values;
          for (final val in values) {
            FlutterLogs.logInfo('envio', 'estado', 'enviando');
            print(jsonEncode(val.toJson()));
            var response = await _uploadSavedRegister(
                register: jsonEncode(val.toJson()), uri: uri);
            if (response.statusCode == 200) {
              FlutterLogs.logInfo('envio', 'estado', 'enviado con exito');
              FlutterLogs.logInfo('envio', 'estado', 'borrando');
              val.delete();
            } else {
              print(response.toString());
              print(response.statusCode);
              FlutterLogs.logWarn('envio', 'estado', 'error');
              continue;
            }
          }
        } else {
          FlutterLogs.logInfo('envio', 'estado', 'no hay registros');
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _periodicTryUpload(
        box: _acqBox, uri: Uri.parse('$_url/DataTaskLogger/AddDataTaskLogger'));
    _periodicTryUpload(
        box: _posBox, uri: Uri.parse('$_url/GeoLocation/AddDeviceLocation'));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Packet>('acquisitionBox').listenable(),
          builder: (context, value, child) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: value.length,
              itemBuilder: (context, index) {
                final acq = value.getAt(index);
                return ListTile(
                  title: Text(acq!.guidNumber.toString()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
