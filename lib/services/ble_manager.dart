import 'bluetooth_service.dart';

class BleManager {
  static final BleManager _instance = BleManager._internal();

  factory BleManager() => _instance;

  BleManager._internal();

  final BluetoothService service = BluetoothService();
}