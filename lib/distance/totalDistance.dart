library globals;

import 'package:geolocator/geolocator.dart';

bool isCalculating = false;
List<dynamic> latlngList = [];
double totalDistance = 0;

void appendLatlngList(position) {
  dynamic data = {"lat": position.latitude, "lng": position.longitude};
  print(data);
  latlngList.add(data);
  if (latlngList.length >= 2) {
    totalDistance += Geolocator.distanceBetween(
        latlngList[latlngList.length - 2]["lat"],
        latlngList[latlngList.length - 2]["lng"],
        latlngList[latlngList.length - 1]["lat"],
        latlngList[latlngList.length - 1]["lng"]);
  }
}

void startTotalDistance() {
  // _setTotalDistance = false;
  isCalculating = true;
  print("start clicked");
}

void resetTotalDistance() {
  // _setTotalDistance = false;
  latlngList.clear();
  totalDistance = 0;
  isCalculating = false;
  print("reset clicked");
}

// void calculateTotalDistance() {
//   for (var i = 0; i < latlngList.length - 1; i++) {
//     totalDistance += Geolocator.distanceBetween(
//         latlngList[i]["lat"],
//         latlngList[i]["lng"],
//         latlngList[i + 1]["lat"],
//         latlngList[i + 1]["lng"]);
//   }
// }

// class TotalDistance {
//
//   static final TotalDistance _totalDistance = TotalDistance._internal();
//
//   // passes the instantiation to the _totalDistance object
//   factory TotalDistance() => _totalDistance;
//
//   //initialize variables in here
//   TotalDistance._internal() {
//     _myVariable = 0;
//   }
//
//   int _myVariable;
//
//   //short getter for my variable
//   int get myVariable => _myVariable;
//
//   //short setter for my variable
//   set myVariable(int value) => myVariable = value;
//
//   void incrementMyVariable() => _myVariable++;
// }
