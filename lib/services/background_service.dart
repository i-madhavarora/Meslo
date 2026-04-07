import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'ble_manager.dart';

class BleTaskHandler extends TaskHandler {
  final ble = BleManager().service;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("Background BLE started");
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    await ble.autoReconnect();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print("Background stopped");
  }
}