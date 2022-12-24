import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:rest_api_login/utils/api.dart';
import 'package:http/http.dart' as http;

import '../utils/geo_location.dart';
import '../utils/http_exception.dart';

class SendLocation {
  static Future<void> sendLocation() async {
    String mainUrl = Api.authUrl;
    try {
      final url = '$mainUrl/api/location';
      final Position position = await LocationServices().determinePosition();
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'latitude': position.latitude,
            'longitude': position.longitude,
          }),
          headers: {
            "Content-Type": "application/json",
          });

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (e) {
      throw e;
    }
  }
}
