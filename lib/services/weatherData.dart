import './weatherModel.dart';

/// Derived model class used in the UI
class WeatherData {
  final int cond;
  final double temp;
  final String description;
  final DateTime date;
  final String icon;
  final String city;

  WeatherData(this.cond, this.temp, this.description, this.date, this.icon, this.city);
  String get iconUrl => "https://openweathermap.org/img/wn/$icon@2x.png";

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }
}
