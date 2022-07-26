import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import './geolocator/totalDistance.dart' as total_distance;
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform;

class GeolocationMap extends StatefulWidget {
  const GeolocationMap({Key? key}) : super(key: key);

  @override
  State<GeolocationMap> createState() => _GeolocationMapState();
}

class _GeolocationMapState extends State<GeolocationMap> {
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double?> _centerCurrentLocationStreamController;
  final MapController _mapController = MapController();
  final PanelController _sliderController = PanelController();

  late bool _isNavigate = false;
  List? _shorelineData;
  double? totalDistance;
  double? _bearing; // current bearing
  LatLng? _currLatLang;
  _ShortestShorelinePt? _shortestShorelinePt;
  final List<Marker> _markers = [];
  final List<Polyline> _lineBtwnPts = [];
  bool _sliderOpen = false;
  bool _setTotalDistance = false;
  double? _gpsSpeed;

  @override
  void initState() {
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double?>();

    _checkPermission();
    FlutterCompass.events?.listen((event) {
      setState(() {
        _bearing = event.heading;
      });
      print(_bearing);
    });

    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
    )).listen((position) {
      setState(() {
        _currLatLang = LatLng(position.latitude, position.longitude);
        _gpsSpeed = position.speed;
        if (_isNavigate) {
          _addMarker();
          _addLine();
        }
      });
    });
    _loadShorelinesJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry radius = const BorderRadius.only(
      topLeft: Radius.circular(38.0),
      topRight: Radius.circular(38.0),
    );
    var cardTextStyle = const TextStyle(
        fontFamily: "Montserrat Regular", fontSize: 14, color: Colors.white);

    double cardHeight =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.15
            : MediaQuery.of(context).size.height * 0.2;

    double cardWidth =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.32
            : MediaQuery.of(context).size.width * 0.32;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: const Color(0xff392850),
      ),
      body: SlidingUpPanel(
        controller: _sliderController,
        minHeight: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.035
            : MediaQuery.of(context).size.height * 0.08,
        maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.2
            : MediaQuery.of(context).size.height * 0.3,
        borderRadius: radius,
        color: const Color(0xff392850),
        panel: Column(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width / 6,
              height: 25,
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.deepPurple)),
                  onPressed: () {
                    if (_sliderOpen) {
                      print('open');
                      _sliderController.close();
                    } else {
                      _sliderController.open();
                    }
                    _sliderOpen = !_sliderOpen;
                  },
                  child: SizedBox(width: 600, child: Icon(Icons.menu)))),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: cardHeight,
                width: cardWidth,
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
                          Text(
                            "0 m/s",
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Speed w.r.t water',
                            style: cardTextStyle,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    )),
              ),
              SizedBox(
                height: cardHeight,
                width: cardWidth,
                child: Stack(alignment: Alignment.center, children: <Widget>[
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
                          width: double.maxFinite,
                          child: Column(
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
                              height: double.maxFinite,
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
                                  Text(
                                    "${total_distance.totalDistance.toStringAsFixed(3)} m",
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
              ),
              SizedBox(
                height: cardHeight,
                width: cardWidth,
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
                          Text(
                            "${_gpsSpeed?.toStringAsFixed(3) ?? 0} m/s",
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'GPS Speed',
                            style: cardTextStyle,
                          )
                        ],
                      ),
                    )),
              ),
            ],
          )
        ]),
        body: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 13,
              maxZoom: 19,
              // Stop centering the location marker on the map if user interacted with the map.
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  setState(
                    () =>
                        _centerOnLocationUpdate = CenterOnLocationUpdate.never,
                  );
                }
              },
            ),
            layers: [
              MarkerLayerOptions(
                markers: _markers,
              ),
              PolylineLayerOptions(
                polylines: _lineBtwnPts,
              )
            ],
            // ignore: sort_child_properties_last
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/spoodermanpaowr/cl3b2xkq1001d14rv1yj4qb35/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3Bvb2Rlcm1hbnBhb3dyIiwiYSI6ImNsM2IxcXc1cjBiNG8zam8xejB6NGlkbjQifQ.8MmkgU7FNT-AV1dSwIibOA',
                  subdomains: ['a', 'b', 'c'],
                  maxZoom: 19,
                ),
              ),
              LocationMarkerLayerWidget(
                  plugin: LocationMarkerPlugin(
                    centerCurrentLocationStream:
                        _centerCurrentLocationStreamController.stream,
                    centerOnLocationUpdate: _centerOnLocationUpdate,
                  ),
                  options: LocationMarkerLayerOptions()),
            ],
            nonRotatedChildren: [
              Positioned(
                right: 20,
                bottom:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.35 //3
                        : MediaQuery.of(context).size.height * 0.55,
                child: FloatingActionButton(
                  onPressed: () async {
                    // Automatically center the location marker on the map when location updated until user interact with the map.
                    setState(() {
                      _centerOnLocationUpdate = CenterOnLocationUpdate.always;
                      _isNavigate = true;
                    });
                    // Center the location marker on the map and zoom the map to level 18.
                    _centerCurrentLocationStreamController.add(14);
                    _mapController.rotate(-_bearing!);
                    _nearestShorelineLatLng(_shorelineData);
                    _addMarker();
                    _addLine();
                  },
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.35
                        : MediaQuery.of(context).size.height * 0.55,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    // Automatically center the location marker on the map when location updated until user interact with the map.
                    setState(() {
                      _centerOnLocationUpdate = CenterOnLocationUpdate.always;
                      _isNavigate = false;
                      _markers.clear();
                      _lineBtwnPts.clear();
                    });
                    // Center the location marker on the map and zoom the map to level 18.
                  },
                  child: const Icon(
                    Icons.location_disabled,
                    color: Colors.white,
                  ),
                ),
              )
            ]),
      ),
    );
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
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

  void _loadShorelinesJson() async {
    var response =
        await rootBundle.loadString('assets/shorelines/shorelines.json');
    setState(() => _shorelineData = json.decode(response));
  }

  void _nearestShorelineLatLng(shorelines) {
    double shortestDistance = double.infinity;
    for (var latlong in shorelines) {
      double distance = Geolocator.distanceBetween(_currLatLang!.latitude,
          _currLatLang!.longitude, latlong["latitude"]-0.01, latlong["longitude"]);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        LatLng shortestPoint =
            LatLng(latlong["latitude"]-0.01, latlong["longitude"]);
        _shortestShorelinePt =
            _ShortestShorelinePt(shortestPoint, shortestDistance);
      }
    }
    print(_shortestShorelinePt?.point);
    print(_shortestShorelinePt?.distance);
  }

  void _addMarker() {
    Marker marker = Marker(
      point: _shortestShorelinePt!.point,
      builder: (ctx) => Container(
        child: const Icon(
          Icons.location_on,
          size: 30,
          color: Colors.red,
        ),
      ),
    );
    setState(() {
      _markers.clear();
      _markers.add(marker);
    });
  }

  void _addLine() {
    List<LatLng> pointsForLine = [];
    pointsForLine.add(_currLatLang!);
    pointsForLine.add(_shortestShorelinePt!.point);
    Polyline line = Polyline(
        points: pointsForLine,
        strokeWidth: 3.0,
        color: const Color(0xCCCCFFFF));
    setState(() {
      _lineBtwnPts.clear();
      _lineBtwnPts.add(line);
    });
  }
}

class _ShortestShorelinePt {
  _ShortestShorelinePt(this.point, this.distance);

  final LatLng point;
  final double distance;
}
