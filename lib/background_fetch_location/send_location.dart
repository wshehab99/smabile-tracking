import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/geo_location.dart';

class SendLocation {
  static Future<void> sendLocation() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      print("no key found");
    } else {
      final extractedUserData =
          Map<String, dynamic>.from(json.decode(pref.getString('userData')!));

      final expiryDate =
          DateTime.parse(extractedUserData['expiryDate'].toString());
      if (expiryDate.isBefore(DateTime.now())) {
      } else {
        try {
          String _token = extractedUserData['token'].toString();
          final String url = 'https://crm.mz-solution.com/api/store-location';
          final Position position =
              await LocationServices().determinePosition();
          final response = await http.post(
            Uri.parse(url),
            body: json.encode({
              'lat': position.latitude,
              'lng': position.longitude,
            }),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $_token",
            },
          );

          final responseData = json.decode(json.encode(response.body));
          print(responseData);

          print(response.statusCode);
        } catch (error) {
          print(error);
        }
      }
    }
  }
}
