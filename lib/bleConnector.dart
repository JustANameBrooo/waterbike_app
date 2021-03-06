library globals;

import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

bool connected = false;
final devices = <DiscoveredDevice>[];

final ble = FlutterReactiveBle();
late StreamSubscription<ConnectionStateUpdate> connection;
late Stream<ConnectionStateUpdate> currentConnectionStream;

Future<void> connect (String deviceId) async {
  currentConnectionStream = ble.connectToAdvertisingDevice(
    id:deviceId,
    prescanDuration: const Duration(seconds: 5),
    withServices: [],
  ).asBroadcastStream();
  print("Is broadcast");
  print(currentConnectionStream.isBroadcast);
  print("if test doesnt print after connection failed");
  connection = currentConnectionStream.listen((event) async {
    var id = event.deviceId.toString();
    print("test" + id);
    switch (event.connectionState) {
      case DeviceConnectionState.connecting:
        {
          print("Connecting to" + id);
          break;
        }
      case DeviceConnectionState.connected:
        {
          connected = true;
          print("Connected to" + id);
          break;
        }
      case DeviceConnectionState.disconnecting:
        {
          connected = false;
          print("Disconnecting from" + id);
          break;
        }
      case DeviceConnectionState.disconnected:
        {
          print("Disconnected from" + id);
          break;
        }
    }
  });
}

void disconnect(String deviceId) async {
  try {
    await connection.cancel();
  } on Exception catch (e, _) {
    print("Error disconnecting from a device: $e");
  } finally {
    connected = false;
  }
}
