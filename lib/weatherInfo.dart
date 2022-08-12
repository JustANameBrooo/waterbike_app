import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import './services/weatherModel.dart';
import './services/weatherData.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({Key? key}) : super(key: key);

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  WeatherModel weatherModel = WeatherModel();
  String cityName = '';
  List<WeatherData>? weatherDataList = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      var forecasts = await weatherModel.getLocationWeather();
      //here is the async code, you can execute any async code here
      print("forecasts");
      print(forecasts);
      updateForecast(forecasts);
      super.initState();
    });
  }

  void updateForecast(dynamic forecasts) async {
    setState(() {
      weatherDataList?.clear();
      if (forecasts != null) {
        final steps = [0, 8, 16, 24];
        print("heyheyhey");
        print(forecasts["list"]);
        for (int step in steps) {
          double celcius = (forecasts["list"][step]["main"]["temp"] - 273.15);
          WeatherData weatherdata = WeatherData(
              forecasts["list"][step]["weather"][0]["id"],
              celcius,
              forecasts["list"][step]["weather"][0]["description"],
              DateTime.fromMillisecondsSinceEpoch(
                  forecasts["list"][step]["dt"] * 1000),
              forecasts["list"][step]["weather"][0]["icon"],
              forecasts["city"]['name']);
          weatherDataList?.add(weatherdata);
          cityName = forecasts["city"]['name'];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32.0))),
      backgroundColor: Color(0xff63768d),
      title: const Text(
        'Weather Conditions',
        style: TextStyle(
            fontSize: 25.0, fontFamily: 'Spartan MB', color: Color(0xffffffff)),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextButton(
            onPressed: () async {
              var weatherData = await weatherModel.getLocationWeather();
              updateForecast(weatherData);
            },
            child: Text(
              'Get Weather Forecast for Current Location',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                fontFamily: 'Spartan MB',
                color: Color(0xffffffff),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: TextField(
                  style: TextStyle(color: Color(0xFF000000)),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFFFFFFF),
                      hintText: 'Enter City name',
                      hintStyle: TextStyle(color: Color(0xff554971)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide.none,
                      )),
                  onChanged: (value) {
                    cityName = value;
                  },
                  onSubmitted: (value) async {
                    cityName = value;
                    if (cityName != null) {
                      var weatherData =
                          await weatherModel.getCityWeather(cityName);
                      print(cityName);
                      updateForecast(weatherData);
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (cityName != null) {
                    var weatherData =
                        await weatherModel.getCityWeather(cityName);
                    print("cccciitytyy");
                    print(weatherData);
                    updateForecast(weatherData);
                  }
                },
                child: const Icon(
                  Icons.near_me,
                  color: Color(0xffffffff),
                  size: 30.0,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weatherDataList!
                .map(
                  (forecast) => Expanded(
                    child: Column(
                      children: [
                        Text(DateFormat.E().format(forecast.date),
                            style: TextStyle(
                                color: Color(0xffffffff),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        WeatherIconImage(iconUrl: forecast.iconUrl, size: 45),
                        const SizedBox(height: 2),
                        Text(
                          forecast.temp.toStringAsFixed(1) + "°C",
                          style: TextStyle(
                            color: Color(0xffffffff),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            //weatherDataList!.map((weatherData) => ForecastItem(forecast: weatherData)).toList(),
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
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherIconImage extends StatelessWidget {
  const WeatherIconImage({Key? key, required this.iconUrl, required this.size})
      : super(key: key);
  final String iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: iconUrl,
      width: size,
      height: size,
    );
  }
}
