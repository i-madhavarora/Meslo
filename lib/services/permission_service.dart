import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestAll() async {
    await [
      Permission.bluetooth,
      Permission.microphone,
      Permission.location,
    ].request();
  }
}