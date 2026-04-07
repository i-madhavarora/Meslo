import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> request() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.microphone,
      Permission.location,
    ].request();

    return await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted;
  }
}