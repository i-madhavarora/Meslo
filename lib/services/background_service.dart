import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'ble_manager.dart';

class BleTaskHandler extends TaskHandler {
  final ble = BleManager().service;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print("Background BLE started");
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // 🔁 runs periodically
    await ble.autoReconnect();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print("Background stopped");
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
  }
}