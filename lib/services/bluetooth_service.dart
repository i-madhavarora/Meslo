import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  Function(String sender)? onPairRequest;
  final List<ScanResult> results = [];
  String deviceId = "";
  String? remoteDeviceId;

  final List<BluetoothDevice> connectedDevices = [];
  final List<BluetoothCharacteristic> txCharacteristics = [];
  final List<BluetoothCharacteristic> rxCharacteristics = [];
  BluetoothCharacteristic? txCharacteristic;
  BluetoothCharacteristic? rxCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  bool isScanning = false;
  bool isConnected = false;

  String? sessionId;
  bool isPaired = false;

  static const String HELLO = "HELLO";
  static const String PAIR_REQUEST = "PAIR_REQUEST";
  static const String PAIR_ACCEPT = "PAIR_ACCEPT";
  static const String CHAT = "CHAT";

  final Set<String> seenMessages = {};

  Future<void> autoReconnect() async {
    if (connectedDevice != null && !isConnected) {
      try {
        await connectedDevice!.connect();
        await _discoverServices();
        await sendHandshake();
      } catch (e) {
        print("Reconnect failed");
      }
    }
  }

  Future<void> sendPairRequest(String targetId) async {
    await sendMessage("PAIR_REQUEST", targetId);
  }

  Future<void> acceptPair(String targetId) async {
    sessionId = "${deviceId}_$targetId";
    isPaired = true;

    await sendMessage("PAIR_ACCEPT", sessionId!);
  }

  Future<void> sendHandshake() async {
    await sendMessage("HELLO", "INIT");
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
        results
          ..clear()
          ..addAll(res);
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

      connectedDevices.add(device);

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

        if (props.write || props.writeWithoutResponse) {
          txCharacteristics.add(char);
        }

        if (props.notify || props.indicate) {
          rxCharacteristics.add(char);

          await char.setNotifyValue(true);

          char.lastValueStream.listen((value) {
            _handleIncoming(value);
          });
        }
      }
    }
  }

  void _handleIncoming(List<int> value) {
    final msg = String.fromCharCodes(value);

    final parts = msg.split("|");
    if (parts.length < 4) return;

    final type = parts[0];
    final sender = parts[1];
    final msgId = parts[2];
    final data = parts.sublist(3).join("|");

    if (seenMessages.contains(msgId)) return;
    seenMessages.add(msgId);

    print("[$type] from $sender: $data");

    // 🔁 forward to all
    _broadcast(msg);
  }

  Future<void> _broadcast(String msg) async {
    for (var tx in txCharacteristics) {
      try {
        await tx.write(msg.codeUnits);
      } catch (e) {
        print("Broadcast error: $e");
      }
    }
  }

  Future<void> sendChat(String msg) async {
    if (!isPaired) {
      print("Not paired yet!");
      return;
    }

    await sendMessage("CHAT", msg);
  }

  // ---------------- DISCONNECT ----------------
  Future<void> disconnect() async {
    try {
      await connectedDevice?.disconnect();
      isConnected = false;
      connectedDevice = null;

      await _connSub?.cancel();
      _connSub = null;
    } catch (e) {
      print("DISCONNECT ERROR: $e");
    }
  }

  // ---------------- SEND MESSAGE ----------------
  Future<void> sendMessage(String type, String data) async {
    final msgId = DateTime.now().millisecondsSinceEpoch.toString();
    final msg = "$type|$deviceId|$msgId|$data";

    await _broadcast(msg);
  }
}