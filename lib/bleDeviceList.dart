import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import './bleConnector.dart' as bluetooth;

class BLEDeviceList extends StatefulWidget {
  const BLEDeviceList({Key? key}) : super(key: key);

  @override
  State<BLEDeviceList> createState() => _BLEDeviceListState();
}

class _BLEDeviceListState extends State<BLEDeviceList> {
  StreamSubscription? _subscription;
  BleStatus? _bleStatus;

  final ble = bluetooth.ble;

  // bool connected = false;

  @override
  void initState() {
    ble.statusStream.listen((status) {
      //code for handling status update
      setState(() {
        _bleStatus = ble.status;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scanned Devices'),
      content: SizedBox(
        height: 500,
        width: 500,
        child: ble.status == BleStatus.ready
            ? Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        child: const Text('Scan'),
                        onPressed: () {
                          setState(() {
                            startScan();
                          });
                        }),
                    ElevatedButton(
                        child: const Text('Stop'),
                        onPressed: () {
                          setState(() {
                            stop();
                          });
                        }),
                  ],
                ),
                Flexible(
                  child: ListView(
                    children: bluetooth.devices
                        .map(
                          (device) => Card(
                            child: ListTile(
                              title: Text(device.name),
                              subtitle:
                                  Text("${device.id}\nRSSI: ${device.rssi}"),
                              trailing: IconButton(
                                color: bluetooth.connected
                                    ? Colors.blue
                                    : Colors.red,
                                onPressed: () async {
                                  bluetooth.connected
                                      ? bluetooth.disconnect(device.id)
                                      : await bluetooth.connect(device.id);
                                  // setState(() {});
                                  print(bluetooth.connection);
                                  print(bluetooth.connected);
                                },
                                icon: Icon(Icons.bluetooth),
                                splashRadius: 25,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ])
            : Text(_bleStatus.toString()),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, bluetooth.devices),
          child: const Text('OK'),
        ),
      ],
    );
  }

  void startScan() {
    bluetooth.devices.clear();
    _subscription?.cancel();
    _subscription = ble.scanForDevices(withServices: []).listen((device) {
      final knownDeviceIndex =
          bluetooth.devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        setState(() {
          bluetooth.devices[knownDeviceIndex] = device;
        });
      } else {
        setState(() {
          bluetooth.devices.add(device);
        });
      }
    });
  }

  void stop() {
    setState(() async {
      await _subscription?.cancel();
      _subscription = null;
    });
  }
}
