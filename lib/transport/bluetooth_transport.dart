import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothTransport {
  final _ble = FlutterBluePlus();

  BluetoothDevice? device;
  BluetoothCharacteristic? writeChar;
  BluetoothCharacteristic? notifyChar;

  final _controller = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get onMessageReceived => _controller.stream;

  // 🔍 SCAN
  Stream<List<ScanResult>> scan() async* {
    await _ble.startScan(timeout: const Duration(seconds: 5));

    yield* _ble.scanResults;

    await Future.delayed(const Duration(seconds: 5));
    _ble.stopScan();
  }

  // 🔗 CONNECT
  Future<void> connect(BluetoothDevice d) async {
    device = d;

    await d.connect(autoConnect: false);

    var services = await d.discoverServices();

    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properties.write) writeChar = c;

        if (c.properties.notify) {
          notifyChar = c;
          await c.setNotifyValue(true);

          c.lastValueStream.listen((value) {
            _controller.add(Uint8List.fromList(value));
          });
        }
      }
    }
  }

  // 📤 SEND
  Future<void> send(Uint8List data) async {
    if (writeChar == null) return;
    await writeChar!.write(data, withoutResponse: false);
  }

  // 🔌 DISCONNECT
  Future<void> disconnect() async {
    await device?.disconnect();
  }
}