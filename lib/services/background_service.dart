import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'ble_manager.dart';

class BleTaskHandler extends TaskHandler {
  final ble = BleManager().service;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print("Background BLE started");
  }

  // ✅ REQUIRED in your version
  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    await ble.autoReconnect();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print("Background stopped");
  }
}