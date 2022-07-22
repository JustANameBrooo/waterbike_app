import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'bleConnector.dart';

class BleConnector {
  final Uuid serviceUuid = Uuid.parse("44d55770-bd07-4ce7-8ff9-c564c9c9b24a");
  final Uuid batteryUuid =
      Uuid.parse("62391be9-a26b-4a82-8a13-e4db229df11e");
  final Uuid waterSpeedUuid =
      Uuid.parse("a56f6a0e-164d-4d7c-b4cd-74afbdfeaf1f");

  final ble = FlutterReactiveBle();
  late StreamSubscription<ConnectionStateUpdate> connection;

  final connectedDevices = <ConnectedDevice>[];
  int? batteryGauge;
  List<int>? waterSpeed;

  // final deviceConnectionController = StreamController<ConnectedDevice>();
  final connectedDevicesController = StreamController<List<ConnectedDevice>>();
  final batteryGaugeController = StreamController<int?>();
  final waterSpeedController = StreamController<List<int>?>();

  //Stream get deviceConnectionStream => deviceConnectionController.stream;

  Stream get connectedDevicesStream => connectedDevicesController.stream;
  Stream get batteryGaugeStream => batteryGaugeController.stream;
  Stream get waterSpeedStream => waterSpeedController.stream;

  Future<void> connect(String deviceId, String deviceName) async {
    // currentConnectionStream = ble.connectToAdvertisingDevice(
    //   id: deviceId,
    //   prescanDuration: const Duration(seconds: 5),
    //   withServices: [],
    // );
    print("if test doesnt print after connection failed");
    connection = ble
        .connectToDevice(
            id: deviceId, connectionTimeout: const Duration(seconds: 3))
        .listen((event) async {
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
            ConnectedDevice connectedDevice =
                ConnectedDevice(connection, event, deviceName);
            connectedDevices.add(connectedDevice);
            connectedDevicesController.add(connectedDevices);

            // notifyListeners();
            print("Connected to " + id);
            await readCharacteristic(deviceId);
            var batteryStream = subscribeBatteryStream(deviceId);
            batteryStream.listen((event) {
              print(event.toString());
              print("BATTERY");
              for (var value in event) {
                print(String.fromCharCode(value));
              }
              batteryGauge = event[0];
              batteryGaugeController.add(batteryGauge);
            });
            var waterSpeedStream = subscribeWaterStream(deviceId);
            waterSpeedStream.listen((event) {
              print(event.toString());
              print("WATER SPEED");
              for (var value in event) {
                print(String.fromCharCode(value));
              }
              waterSpeed = event;
              waterSpeedController.add(waterSpeed);
            });
            // subscribeCharacteristic(deviceId);
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

  Future<void> disconnect(ConnectedDevice connectedDevice) async {
    try {
      await connectedDevice.connection.cancel();
      connectedDevices.remove(connectedDevice);
      connectedDevicesController.add(connectedDevices);
      // notifyListeners();
    } on Exception catch (e, _) {
      print("Error disconnecting from a device: $e");
    } finally {
      //connected = false;
      print("Disconnected");
    }
  }

  Future<void> readCharacteristic(String deviceId) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: batteryUuid,
        deviceId: deviceId);
    final response = await ble.readCharacteristic(characteristic);
    print("read_characteristics " + response.toString());
  }

  // void subscribeCharacteristic(String deviceId) {
  //   final characteristic = QualifiedCharacteristic(
  //       serviceId: serviceUuid,
  //       characteristicId: BATTERY_CHARACTERISTIC_UUID,
  //       deviceId: deviceId);
  //
  //   ble.subscribeToCharacteristic(characteristic).listen((data) {
  //     // code to handle incoming data
  //     print('Data received $data');
  //   }, onError: (dynamic error) {
  //     // code to handle errors
  //     print('Subscribe error $error');
  //   });
  // }

  Stream<List<int>> subscribeBatteryStream(deviceId) async* {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: batteryUuid,
        deviceId: deviceId);
    while (true) {
      final response = await ble.readCharacteristic(characteristic);
      yield response;
    }
  }

  Stream<List<int>> subscribeWaterStream(deviceId) async* {
    final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: waterSpeedUuid,
        deviceId: deviceId);
    while (true) {
      final response = await ble.readCharacteristic(characteristic);
      yield response;
    }
  }

}

class ConnectedDevice {
  ConnectedDevice(this.connection, this.connectedDeviceState, this.deviceName);

  final StreamSubscription<ConnectionStateUpdate> connection;
  final ConnectionStateUpdate connectedDeviceState;
  final String deviceName;
}
