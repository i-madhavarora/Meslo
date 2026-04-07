import 'dart:math';

class DeviceIdentity {
  static String generateId() {
    final rand = Random();
    return "MESLO-${rand.nextInt(9000) + 1000}";
  }
}