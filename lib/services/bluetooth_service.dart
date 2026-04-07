import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  final List<ScanResult> results = [];
  StreamSubscription<List<ScanResult>>? _scanSub;

  bool isScanning = false;

  Future<void> startScan() async {
    results.clear();

    try {
      isScanning = true;

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

      _scanSub?.cancel();

      _scanSub = FlutterBluePlus.scanResults.listen((res) {
        results
          ..clear()
          ..addAll(res);
      });
    } catch (e) {
      print("START SCAN ERROR: $e");
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      isScanning = false;
      await _scanSub?.cancel();
      _scanSub = null;
    } catch (e) {
      print("STOP SCAN ERROR: $e");
    }
  }

  void dispose() {
    _scanSub?.cancel();
  }
}
