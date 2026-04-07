import 'package:flutter/material.dart';
import '../../services/bluetooth_service.dart';
import '../../services/permission_service.dart';

class BluetoothTestScreen extends StatefulWidget {
  const BluetoothTestScreen({super.key});

  @override
  State<BluetoothTestScreen> createState() => _BluetoothTestScreenState();
}

class _BluetoothTestScreenState extends State<BluetoothTestScreen> {
  final service = BluetoothService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Test")),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final ok = await PermissionService.request();
                  if (ok) await service.startScan();
                  setState(() {});
                },
                child: const Text("Start Scan"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await service.stopScan();
                  setState(() {});
                },
                child: const Text("Stop Scan"),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: service.results.length,
              itemBuilder: (context, i) {
                final r = service.results[i];
                return ListTile(
                  title: Text(r.device.platformName),
                  subtitle: Text(r.device.remoteId.toString()),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}