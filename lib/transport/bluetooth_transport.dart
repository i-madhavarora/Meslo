import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothTransport {
  final flutterBlue = FlutterBluePlus();

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
    );
  }

  void listenDevices() {
    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        print(r.device.platformName);
      }
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }
}