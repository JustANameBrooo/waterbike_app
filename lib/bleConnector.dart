import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'bleConnector.dart';

class BleConnector {
  final ble = FlutterReactiveBle();
  late StreamSubscription<ConnectionStateUpdate> connection;

  // bool connected = false;
  final connectedDevices = <ConnectedDevice>[];

  // late Stream<ConnectionStateUpdate> currentConnectionStream;
  Stream<ConnectionStateUpdate> get state => deviceConnectionController.stream;
  final deviceConnectionController = StreamController<ConnectionStateUpdate>();

  final Uuid _myServiceUuid =
      Uuid.parse("19b10000-e8f2-537e-4f6c-6969768a1214");
  final Uuid _myCharacteristicUuid =
      Uuid.parse("19b10001-e8f2-537e-4f6c-6969768a1214");

  Future<void> connect(String deviceId, String deviceName) async {
    // currentConnectionStream = ble.connectToAdvertisingDevice(
    //   id: deviceId,
    //   prescanDuration: const Duration(seconds: 5),
    //   withServices: [],
    // );
    print("if test doesnt print after connection failed");
    connection = ble
        .connectToDevice(
            id: deviceId, connectionTimeout: const Duration(seconds: 5))
        .listen((event) {
      var id = event.deviceId.toString();
      print("test" + id);
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            print("Connecting to " + id);
            break;
          }
        case DeviceConnectionState.connected:
          {
            //connected = true;
            deviceConnectionController.add(event);
            ConnectedDevice connectedDevice =
                ConnectedDevice(connection, event, deviceName);
            connectedDevices.add(connectedDevice);
            print("Connected to " + id);
            //final characteristic = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: characteristicUuid, deviceId: deviceId);
            //final response = await ble.readCharacteristic(characteristic);
            //print(response.toString());
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            //connected = false;
            print("Disconnecting from " + id);
            connection.cancel();
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            print("Disconnected from " + id);
            connection.cancel();
            break;
          }
      }
    }, onError: (Object error) {
      // Handle a possible error
      connection.cancel();
      print('Connecting to device $deviceId resulted in error $error');
    });
  }

  void disconnect(ConnectedDevice connectedDevice) async {
    try {
      await connectedDevice.connection.cancel();
    } on Exception catch (e, _) {
      print("Error disconnecting from a device: $e");
    } finally {
      //connected = false;
      deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: connectedDevice.connectedDeviceState.deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
      print("Disconnected, State of connected device: " +
          connectedDevice.deviceName +
          " is " +
          connectedDevice.connection.toString());
      connectedDevices.remove(connectedDevice);
    }
  }
}

class ConnectedDevice {
  ConnectedDevice(this.connection, this.connectedDeviceState, this.deviceName);

  final StreamSubscription<ConnectionStateUpdate> connection;
  final ConnectionStateUpdate connectedDeviceState;
  final String deviceName;
}
