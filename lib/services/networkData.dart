import 'dart:convert';

import 'package:http/http.dart' as http;

/// weather API network helper
/// pass the weatherAPI url
///  to this class to get geographical coordinates
///
const apiKey = "0f95cc2cda54a193e56a502c88b190b5";

class NetworkData {
  NetworkData(this.url);
  final String url;
  // final apiKey = "25e52f34-0c82-11ed-b697-0242ac130002-25e52fb6-0c82-11ed-b697-0242ac130002";

  ///  'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitide&appid=$apiKey'
  /// get geographical coordinates from open weather API call
  Future getData() async {
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String data = response.body;
      print(data);
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}

