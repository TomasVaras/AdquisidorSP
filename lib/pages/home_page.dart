import 'package:flutter/material.dart';
import 'package:sp_adquisidor_app/widgets/check_and_send_packets_card.dart';
import 'package:sp_adquisidor_app/widgets/data_pos_adq_card.dart';
import 'package:sp_adquisidor_app/widgets/request_permissions_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Column(
        children: const [
          //DataAdquisitionCard(),
          DataAndPositionAcquisitionCard(),
          RequestPermissionsCard(),
          CheckAndSavePacketsCard()
        ],
      ),
    );
  }
}
