import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gridDashboard.dart';
import './bleDeviceList.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'bleConnector.dart';


class HomePageScreen extends StatefulWidget {
  final String ?deviceId;
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
    //deviceConnector = BleDeviceConnector();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isConnected = false;

    return Scaffold(
      backgroundColor: const Color(0xff392850),
      body: Column(
        children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(left: 16, right: 16, top: size.height * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                        textStyle: const TextStyle(
                            color: Color(0xffa29aac),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
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
          const SizedBox(height: 20),
          GridDashboard(bleConnector: bleConnector)
        ],
      ),
    );
  }
}
