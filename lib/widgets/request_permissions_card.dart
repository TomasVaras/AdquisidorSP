import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionsCard extends StatefulWidget {
  const RequestPermissionsCard({super.key});

  @override
  State<RequestPermissionsCard> createState() => _RequestPermissionsCardState();
}

class _RequestPermissionsCardState extends State<RequestPermissionsCard> {
  Color _checkColor = Colors.red;

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.location, Permission.bluetooth].request();
    return statuses.values.toList().every((value) => value.isGranted);
  }

  void _changeCheckColor(bool status) {
    if (status) {
      _checkColor = Colors.green;
    } else {
      _checkColor = Colors.red;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.check,
              color: _checkColor,
            ),
            ElevatedButton(
              onPressed: () async {
                _changeCheckColor(await _requestPermissions());
              },
              child: const Text('request'),
            ),
          ],
        ),
      ),
    );
  }
}
