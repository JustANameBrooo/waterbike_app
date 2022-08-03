import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gridDashboard.dart';
import './bleDeviceList.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'bleConnector.dart';

class HomePageScreen extends StatefulWidget {
  final String? deviceId;

  const HomePageScreen({Key? key, this.deviceId}) : super(key: key);

  @override
  State<HomePageScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageScreen> {
  late TextEditingController _uuidController;

  late final BleConnector bleConnector;

  @override
  void initState() {
    bleConnector = BleConnector();
    bleConnector.connectedDevicesStream.listen((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isConnected = bleConnector.connectedDevices.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xff36213e), //Color(0xff392850),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: 16, right: 16, top: size.height * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 150,
                      width: size.width * 0.7,
                      child: ListView(shrinkWrap: true, children: [
                        Text(
                          "Bluetooth",
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConnected ? "Connected" : "Not Connected",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                                color: isConnected ? Colors.blue :Color(0xffa29aac),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...bleConnector.connectedDevices.map((device) => Text(
                              device.deviceName,
                              style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                      ]),
                      // Container(
                      //   height: 100,
                      //   child: ListView(
                      //     children: bleConnector.connectedDevices
                      //         .map((device) => Text(device.deviceName))
                      //         .toList(),
                      //   ),
                      // ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return BLEDeviceList(bleConnector: bleConnector);
                        });
                  },
                  alignment: Alignment.topCenter,
                  icon: const Icon(
                    Icons.bluetooth,
                    size: 35,
                  ),
                  color: isConnected ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
          //TODO Grid Dashboard
          GridDashboard(bleConnector: bleConnector)
        ],
      ),
    );
  }
}
