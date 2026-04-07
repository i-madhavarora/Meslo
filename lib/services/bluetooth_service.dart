import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  Function(String sender)? onPairRequest;
  final List<ScanResult> results = [];
  String deviceId = "";
  String? remoteDeviceId;

  BluetoothDevice? connectedDevice;
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
      connectedDevice = device;

      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      isConnected = true;

      _connSub = device.connectionState.listen((state) {
        isConnected = state == BluetoothConnectionState.connected;
        print("STATE: $state");
      });

      // 🔥 IMPORTANT: wait a bit before service discovery
      await Future.delayed(const Duration(milliseconds: 800));

      await _discoverServices();
      await sendHandshake();

      return true;
    } catch (e) {
      print("CONNECT ERROR: $e");
      return false;
    }
  }

  // ---------------- DISCOVER SERVICES ----------------
  Future<void> _discoverServices() async {
    if (connectedDevice == null) return;

    try {
      final services = await connectedDevice!.discoverServices();

      for (final service in services) {
        for (final characteristic in service.characteristics) {
          final props = characteristic.properties;

          // TX (send)
          if (props.write || props.writeWithoutResponse) {
            txCharacteristic = characteristic;
          }

          // RX (receive)
          if (props.notify || props.indicate) {
            rxCharacteristic = characteristic;

            await characteristic.setNotifyValue(true);

            characteristic.lastValueStream.listen((value) {
              final msg = String.fromCharCodes(value);
              final parts = msg.split("|");

              if (parts.length < 3) return;

              final type = parts[0];
              final sender = parts[1];
              final data = parts.sublist(2).join("|");

              switch (type) {
                case "HELLO":
                  remoteDeviceId = sender;
                  print("HELLO from $sender");
                  break;

                case "PAIR_REQUEST":
                  remoteDeviceId = sender;
                  onPairRequest?.call(sender);
                  break;

                case "PAIR_ACCEPT":
                  sessionId = data;
                  isPaired = true;
                  print("PAIRED with session: $sessionId");
                  break;

                case "CHAT":
                  if (isPaired) {
                    print("CHAT from $sender: $data");
                  }
                  break;
              }
            });
          }
        }
      }
    } catch (e) {
      print("SERVICE DISCOVERY ERROR: $e");
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
    if (txCharacteristic == null) return;

    final msg = "$type|$deviceId|$data";
    await txCharacteristic!.write(msg.codeUnits);
  }
}