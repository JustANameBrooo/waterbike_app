import 'dart:async';

import 'package:geolocator/geolocator.dart';

class Geolocation {
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
  StreamSubscription<Position>? positionStreamSubscription;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );

  void checkPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are denied');
      }
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Permissions are permanently denied');
      }
    }

    if (positionStreamSubscription == null) {
      final positionStream =
          geolocator.getPositionStream(locationSettings: locationSettings);
      positionStreamSubscription = positionStream.handleError((error) {
        positionStreamSubscription?.cancel();
        positionStreamSubscription = null;
      }).listen((position) {


      });
      positionStreamSubscription?.pause();
    }
  }
}
