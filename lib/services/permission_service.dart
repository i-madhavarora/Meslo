import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> request() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.microphone,
    ].request();

    final bluetoothScan = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    final bluetoothConnect = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    final location = statuses[Permission.location]?.isGranted ?? false;
    final advertise = statuses[Permission.bluetoothAdvertise]?.isGranted ?? false;

    return bluetoothScan && bluetoothConnect && location && advertise;
  }
}