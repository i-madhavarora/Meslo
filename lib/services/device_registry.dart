import 'package:flutter/material.dart';

class DeviceRegistry extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _devices = {};

  Map<String, Map<String, dynamic>> get devices => _devices;

  void updateDevice(String userId, String name) {
    _devices[userId] = {
      "name": name,
      "lastSeen": DateTime.now(),
    };
    notifyListeners();
  }
}