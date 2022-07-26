import './networkData.dart';
import 'package:geolocator/geolocator.dart';

const weatherApiUrl = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {

  Future<dynamic> getLocationWeather() async {
    /// await for methods that return future
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    /// Get location data
    ///&units=metric change the temperature metric
    NetworkData networkHelper = NetworkData(
        '$weatherApiUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

}