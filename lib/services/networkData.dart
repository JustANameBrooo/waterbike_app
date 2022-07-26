import 'dart:convert';

import 'package:http/http.dart' as http;

const apiKey = "0f95cc2cda54a193e56a502c88b190b5";

class NetworkData {
  NetworkData(this.url);
  final String url;
  // final apiKey = "25e52f34-0c82-11ed-b697-0242ac130002-25e52fb6-0c82-11ed-b697-0242ac130002";

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

