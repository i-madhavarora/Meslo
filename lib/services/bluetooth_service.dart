import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../core/encryption.dart';

class BluetoothService {
  Function(String sender)? onPairRequest;

  final List<ScanResult> results = [];

  String deviceId = "";
  String? remoteDeviceId;

  final List<BluetoothDevice> connectedDevices = [];
  final List<BluetoothCharacteristic> txCharacteristics = [];
  final List<BluetoothCharacteristic> rxCharacteristics = [];

  StreamSubscription<List<ScanResult>>? _scanSub;

  bool isScanning = false;
  bool isConnected = false;

  String? sessionId;
  bool isPaired = false;

  static const String HELLO = "HELLO";
  static const String PAIR_REQUEST = "PAIR_REQUEST";
  static const String PAIR_ACCEPT = "PAIR_ACCEPT";
  static const String CHAT = "CHAT";

  final Set<String> seenMessages = {};

  // ---------------- AUTO RECONNECT ----------------
  Future<void> autoReconnect() async {
    for (var device in connectedDevices) {
      try {
        await device.connect(autoConnect: true);
        await Future.delayed(const Duration(milliseconds: 500));
        await _discoverServices(device);
        await sendHandshake();
      } catch (_) {}
    }
  }

  // ---------------- PAIRING ----------------
  Future<void> sendPairRequest(String targetId) async {
    await sendMessage(PAIR_REQUEST, targetId);
  }

  Future<void> acceptPair(String targetId) async {
    sessionId = "${deviceId}_$targetId";
    isPaired = true;

    await sendMessage(PAIR_ACCEPT, sessionId!);
  }

  Future<void> sendHandshake() async {
    await sendMessage(HELLO, "INIT");
  }

  // ---------------- SCAN ----------------
  Future<void> startScan() async {
    results.clear();

    try {
      isScanning = true;

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
      );

      _scanSub?.cancel();

      _scanSub = FlutterBluePlus.scanResults.listen((res) {
        results.clear();

        for (final r in res) {
          final name = r.device.name;

          if (name.isNotEmpty && name.startsWith("EchoMesh")) {
            results.add(r);
          }
        }
      });
    } catch (e) {
      print("SCAN ERROR: $e");
    }
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    isScanning = false;
    await _scanSub?.cancel();
    _scanSub = null;
  }

  // ---------------- CONNECT ----------------
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      );

      if (!connectedDevices.contains(device)) {
        connectedDevices.add(device);
      }

      isConnected = true;

      await Future.delayed(const Duration(milliseconds: 800));
      await _discoverServices(device);
      await sendHandshake();

      return true;
    } catch (e) {
      print("CONNECT ERROR: $e");
      return false;
    }
  }

  // ---------------- DISCOVER SERVICES ----------------
  Future<void> _discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();

    for (final service in services) {
      for (final char in service.characteristics) {
        final props = char.properties;

        // TX
        if ((props.write || props.writeWithoutResponse) &&
            !txCharacteristics.contains(char)) {
          txCharacteristics.add(char);
        }

        // RX
        if ((props.notify || props.indicate) &&
            !rxCharacteristics.contains(char)) {
          rxCharacteristics.add(char);

          await char.setNotifyValue(true);

          char.lastValueStream.listen(_handleIncoming);
        }
      }
    }
  }

  // ---------------- RECEIVE ----------------
  void _handleIncoming(List<int> value) {
    final msg = String.fromCharCodes(value);

    final parts = msg.split("|");
    if (parts.length < 4) return;

    final type = parts[0];
    final sender = parts[1];
    final msgId = parts[2];
    final data = parts.sublist(3).join("|");

    // 🚫 duplicate protection
    if (seenMessages.contains(msgId)) return;
    seenMessages.add(msgId);

    // ---------------- HANDLE TYPES ----------------
    switch (type) {
      case HELLO:
        remoteDeviceId = sender;
        break;

      case PAIR_REQUEST:
        remoteDeviceId = sender;
        onPairRequest?.call(sender);
        break;

      case PAIR_ACCEPT:
        sessionId = data;
        isPaired = true;
        break;

      case CHAT:
        String finalMsg = data;

        if (sessionId != null) {
          try {
            finalMsg = Encryption.decrypt(data, sessionId!);
          } catch (_) {
            print("Decryption failed");
          }
        }

        print("CHAT from $sender: $finalMsg");
        break;
    }

    // 🔁 MESH FORWARD
    _broadcast(msg);
  }

  // ---------------- BROADCAST ----------------
  Future<void> _broadcast(String msg) async {
    for (var tx in txCharacteristics) {
      try {
        await tx.write(msg.codeUnits);
      } catch (e) {
        print("Broadcast error: $e");
      }
    }
  }

  // ---------------- SEND CHAT ----------------
  Future<void> sendChat(String msg) async {
    if (!isPaired) {
      print("Not paired yet!");
      return;
    }

    await sendMessage(CHAT, msg);
  }

  // ---------------- SEND MESSAGE ----------------

  Future<void> sendMessage(String type, String data) async {
    final msgId = DateTime.now().millisecondsSinceEpoch.toString();

    String finalData = data;

    // 🔐 encrypt only chat messages
    if (type == CHAT && sessionId != null) {
      finalData = Encryption.encrypt(data, sessionId!);
    }

    final msg = "$type|$deviceId|$msgId|$finalData";

    await _broadcast(msg);
  }

  // ---------------- DISCONNECT ----------------
  Future<void> disconnect() async {
    try {
      for (var device in connectedDevices) {
        await device.disconnect();
      }

      connectedDevices.clear();
      txCharacteristics.clear();
      rxCharacteristics.clear();

      isConnected = false;
      isPaired = false;
    } catch (e) {
      print("DISCONNECT ERROR: $e");
    }
  }
}