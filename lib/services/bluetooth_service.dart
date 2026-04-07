import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  List<ScanResult> results = [];
  bool isScanning = false;

  Future<void> startScan() async {
    results.clear();

    try {
      isScanning = true;

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
      );

      FlutterBluePlus.scanResults.listen((res) {
        results = res;
      });

    } catch (e) {
      print("Scan error: $e");
    } finally {
      isScanning = false;
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      isScanning = false;
    } catch (e) {
      print("Stop scan error: $e");
    }
  }
}