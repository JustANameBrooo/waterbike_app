import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:waterbike_app/home.dart';
import 'bleConnector.dart';
// import 'bleDeviceConnector.dart';

class BLEDeviceList extends StatefulWidget {
  final BleConnector bleConnector;
  const BLEDeviceList({Key? key, required this.bleConnector}) : super(key: key);

  @override
  State<BLEDeviceList> createState() => _BLEDeviceListState();
}

class _BLEDeviceListState extends State<BLEDeviceList> {
  StreamSubscription? _subscription;
  BleStatus? _bleStatus;
  late final BleConnector bleConnector = widget.bleConnector;
  //late final BleDeviceConnector deviceConnector;
  final devices = <DiscoveredDevice>[];
  // bool connected = false;

  @override
  void initState() {
    // bleConnector = widget.bleConnector;
    bleConnector.ble.statusStream.listen((status) {
      //code for handling status update
      setState(() {
        _bleStatus = bleConnector.ble.status;
      });
    });
    //deviceConnector = BleDeviceConnector();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scanned Devices'),
      content: SizedBox(
        height: 500,
        width: 500,
        child: bleConnector.ble.status == BleStatus.ready
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
                    children: devices
                        .map(
                          (device) => Card(
                            child: ListTile(
                              title: Text(device.name),
                              subtitle:
                                  Text("${device.id}\nRSSI: ${device.rssi}"),
                              trailing: IconButton(
                                color: bleConnector.connected
                                    ? Colors.blue
                                    : Colors.red,
                                onPressed: () async {
                                  bleConnector.connected
                                      ? bleConnector.disconnect(device.id)
                                      : await bleConnector.connect(device.id);
                                  setState(() {});
                                  print(bleConnector.connected);
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
          onPressed: () => Navigator.pop(context, devices),
          child: const Text('OK'),
        ),
      ],
    );
  }

  void startScan() {
    devices.clear();
    _subscription?.cancel();
    _subscription = bleConnector.ble.scanForDevices(withServices: []).listen((device) {
      final knownDeviceIndex =
          devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        setState(() {
          devices[knownDeviceIndex] = device;
        });
      } else {
        setState(() {
          devices.add(device);
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
