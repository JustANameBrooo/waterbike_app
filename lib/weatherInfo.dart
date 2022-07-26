import 'package:flutter/material.dart';
import './services/weatherModel.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({Key? key}) : super(key: key);

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  int? temperature;
  int? condition;
  String cityName = '';
  String? weatherIcon;
  String? tempIcon;
  WeatherModel weatherModel = WeatherModel();

  @override
  void initState () {

    Future.delayed(Duration.zero,() async {
      super.initState();
      var weatherData = await weatherModel.getLocationWeather();
      //here is the async code, you can execute any async code here
      updateUI(weatherData);
    });
  }

  void updateUI(dynamic weather) async {
    setState(() {
      if (weather == null) {
        temperature = 0;
        weatherIcon = 'Error';
        tempIcon = 'Unable to get weather data';
        cityName = '';
        return;
      }
      var condition = weather['weather'][0]['id'];
      weatherIcon = weatherModel.getWeatherIcon(condition);
      double temp = weather['main']['temp'];
      temperature = temp.toInt();

      cityName = weather['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Weather Conditions'),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                    onPressed: () async {
                      var weatherData = await weatherModel.getLocationWeather();
                      updateUI(weatherData);
                    },
                    child: const Icon(
                      Icons.near_me,
                      color: Color(0xFF000000),
                      size: 50.0,
                    )),
              ],
            ),
            Container(
              padding: EdgeInsets.all(5.0),
              child: TextField(
                style: TextStyle(color: Color(0xFF000000)),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                    icon: Icon(
                      Icons.local_activity,
                      color: Color(0xFFFFFFFF),
                    ),
                    hintText: 'Enter City name',
                    hintStyle: TextStyle(color: Color(0xFF000000)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    )),
                onChanged: (value) {
                  cityName = value;
                },
              ),
            ),
            TextButton(
              onPressed: () async {
                if (cityName != null) {
                  var weatherData = await weatherModel.getCityWeather(cityName);
                  print(cityName);
                  updateUI(weatherData);
                }
              },
              child: Text(
                'Get Weather',
                style: TextStyle(fontSize: 20.0, fontFamily: 'Spartan MB', color: Colors.black),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '$temperature°  ',
                    style: TextStyle(
                      fontFamily: 'Spartan MB',
                      fontSize: 40.0,
                    ),
                  ),
                  Text(
                    '$weatherIcon',
                    style: TextStyle(
                      fontSize: 50.0,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  '$cityName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Spartan MB',
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
