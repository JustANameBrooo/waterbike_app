import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:koukicons/speed.dart';
import 'package:koukicons/map2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'geolocation.dart';
import './distance/totalDistance.dart' as total_distance;
import 'bleConnector.dart';
import 'dart:io' show Platform;

class GridDashboard extends StatefulWidget {

  final BleConnector bleConnector;
  const GridDashboard({Key? key, required this.bleConnector}) : super(key: key);

  @override
  State<GridDashboard> createState() => _GridDashboardState();
}

class _GridDashboardState extends State<GridDashboard> {
  double? speed;
  bool _setTotalDistance = false;

  @override
  void initState() {
    _checkPermission();

    late LocationSettings locationSettings;

    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
    );

    // if (Platform.isAndroid) {
    //   locationSettings = AndroidSettings(
    //       accuracy: LocationAccuracy.best,
    //       forceLocationManager: true,
    //       intervalDuration: const Duration(seconds: 3),
    //       //(Optional) Set foreground notification config to keep the app alive
    //       //when going to the background
    //       foregroundNotificationConfig: const ForegroundNotificationConfig(
    //         notificationText:
    //         "Example app will continue to receive your location even when you aren't using it",
    //         notificationTitle: "Running in Background",
    //         enableWakeLock: true,
    //       )
    //   );
    // } else if (Platform.isIOS || Platform.isMacOS) {
    //   locationSettings = AppleSettings(
    //     accuracy: LocationAccuracy.best,
    //     activityType: ActivityType.fitness,
    //     pauseLocationUpdatesAutomatically: true,
    //     // Only set to true if our app will be started up in the background.
    //     showBackgroundLocationIndicator: false,
    //   );
    // } else {
    //   locationSettings = const LocationSettings(
    //     accuracy: LocationAccuracy.best,
    //   );
    // }

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((position) {
      setState(() {
        speed = position.speed;
        if (total_distance.isCalculating) {
          total_distance.appendLatlngList(position);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // style
    var cardTextStyle = const TextStyle(
        fontFamily: "Montserrat Regular", fontSize: 14, color: Colors.white);

    return Flexible(
      child: GridView.count(
        mainAxisSpacing:
            MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 5,
        crossAxisSpacing:
            MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 5,
        primary: false,
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
        children: <Widget>[
          InkWell(
            onTap: () {
            },
            //Battery
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade500,
                        Colors.purple.shade900,
                        Colors.blue.shade900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 100,
                        child: Icon(Icons.battery_0_bar,
                            size: 90, color: Colors.amberAccent),
                      ),
                      Text(
                        "70%",
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Battery',
                        style: cardTextStyle,
                      )
                    ],
                  ),
                )),
          ),
          InkWell(
            //Speed
            onTap: () {},
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade500,
                        Colors.purple.shade900,
                        Colors.blue.shade900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //const Icon(Icons.speed, size: 100, color: Colors.amberAccent),
                      SizedBox(child: KoukiconsSpeed(height: 70), height: 100),
                      Text(
                        "${speed?.toStringAsFixed(3) ?? 0} m/s",
                        style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Speed',
                        style: cardTextStyle,
                      )
                    ],
                  ),
                )),
          ),
          Stack(alignment: Alignment.center, children: <Widget>[
            //Distance Stack
            InkWell(
              onTap: () {
                setState(() {
                  _setTotalDistance = false;
                });
                print('nothing happens');
              },
              child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  child: Container(
                    height: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _setTotalDistance = false;
                              total_distance.startTotalDistance();
                            });
                          },
                          child: Text('Start'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _setTotalDistance = false;
                              total_distance.resetTotalDistance();
                            });
                          },
                          child: Text('Reset'),
                        ),
                      ],
                    ),
                  )),
            ),
            Opacity(
              opacity: _setTotalDistance ? 0.3 : 1,
              child: IgnorePointer(
                ignoring: _setTotalDistance,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _setTotalDistance = true;
                      print("setting distance options");
                    });
                  }, //_setTotalDistance ? null : _distanceClick,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      clipBehavior: Clip.antiAlias,
                      elevation: 4,
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.shade500,
                              Colors.purple.shade900,
                              Colors.blue.shade900
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.moving_outlined,
                                size: 100, color: Colors.greenAccent),
                            Text(
                              total_distance.totalDistance < 1000
                                  ? "${total_distance.totalDistance.toStringAsFixed(3)} m"
                                  : " ${(total_distance.totalDistance / 1000).toStringAsFixed(3)} km",
                              style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Distance',
                              style: cardTextStyle,
                            )
                          ],
                        ),
                      )),
                ),
              ),
            ),
          ]),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GeolocationMap()));
            },
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade500,
                        Colors.purple.shade900,
                        Colors.blue.shade900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                          height: 120,
                          child: KoukiconsMap2(
                            height: 80,
                          )),
                      SizedBox(height: 10),
                      Text(
                        'Navigation',
                        style: cardTextStyle,
                      )
                    ],
                  ),
                )),
          ),
          Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade500,
                      Colors.purple.shade900,
                      Colors.blue.shade900
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 130,
                        child: Image.asset('assets/images/weather.png',
                            scale: 5.5)),
                    Text(
                      'Weather',
                      style: cardTextStyle,
                    )
                  ],
                ),
              )),
          Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade500,
                      Colors.purple.shade900,
                      Colors.blue.shade900
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: 130,
                        child:
                            Image.asset('assets/images/tide.png', scale: 1.3)),
                    Text(
                      'Tidal',
                      style: cardTextStyle,
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
    }
    setState(() {});
  }

  void _startTotalDistance() {
    setState(() {
      _setTotalDistance = false;
      total_distance.isCalculating = true;
      print("start clicked");
    });
  }

  void _resetTotalDistance() {
    setState(() {
      _setTotalDistance = false;
      total_distance.latlngList.clear();
      total_distance.totalDistance = 0;
      total_distance.isCalculating = false;
      print("reset clicked");
    });
  }
}
