import 'package:flutter/material.dart';
import '../../services/ble_manager.dart';
import 'chat_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ble = BleManager().service;

  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    await ble.startScan();
    setState(() {});
  }

  @override
  void dispose() {
    ble.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Devices"),
      ),
      body: ListView.builder(
        itemCount: ble.results.length,
        itemBuilder: (context, index) {
          final result = ble.results[index];
          final device = result.device;

          return ListTile(
            title: Text(
              device.name.isNotEmpty
                  ? device.name
                  : "Unknown Device",
            ),
            subtitle: Text(device.id.id),
            trailing: const Icon(Icons.bluetooth),
            onTap: () async {
              await ble.connect(device);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}