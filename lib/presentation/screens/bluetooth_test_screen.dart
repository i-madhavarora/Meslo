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
  void initState() {
    super.initState();

    // Auto refresh UI every 500ms while scanning
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() {});
      return service.isScanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EchoMesh Bluetooth")),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final ok = await PermissionService.request();
                  if (ok) {
                    await service.startScan();
                    setState(() {});
                  }
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

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: service.results.length,
              itemBuilder: (context, i) {
                final r = service.results[i];
                return ListTile(
                  title: Text(
                    r.device.platformName.isEmpty
                        ? "Unknown Device"
                        : r.device.platformName,
                  ),
                  subtitle: Text(r.device.remoteId.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
