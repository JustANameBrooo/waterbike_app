import './networkData.dart';
import 'package:geolocator/geolocator.dart';

const weatherApiUrl = 'http://api.openweathermap.org/data/2.5/forecast';
const geoApiUrl = 'http://api.openweathermap.org/geo/1.0/direct';

class WeatherModel {

  Future<dynamic> getCityWeather(String cityName) async {
    var url = '$geoApiUrl?q=$cityName&limit=1&appid=$apiKey';
    var weatherDataByCity = await NetworkData(url).getData();
    print("cityLatLong");
    print(weatherDataByCity);
    String latitudeStr = weatherDataByCity[0]["lat"].toStringAsFixed(1);
    String longitudeStr = weatherDataByCity[0]["lon"].toStringAsFixed(1);
    double latitude = double.parse(latitudeStr);
    double longitude = double.parse(longitudeStr);
    print("lat");
    print(latitude);
    var weatherData = await NetworkData(
        '$weatherApiUrl?lat=$latitude&lon=$longitude&appid=$apiKey').getData();
    print("CITYLA");
    print(weatherData);
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    /// await for methods that return future
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    /// Get location data
    ///&units=metric change the temperature metric
    NetworkData networkHelper = NetworkData(
        '$weatherApiUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

}