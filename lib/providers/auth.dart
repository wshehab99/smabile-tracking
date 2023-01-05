import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_api_login/background_fetch_location/location_dialog.dart';
import 'package:rest_api_login/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:rest_api_login/utils/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  var mainUrl = Api.authUrl;

  String? _token;
  String? _userId;
  String? _userEmail;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId!;
  }

  String get userEmail {
    return _userEmail!;
  }

  Future<void> logout() async {
    _token = null;
    _userEmail = null;
    _userId = null;

    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future checkBackgroundPermissions(BuildContext context) async {
    bool isDismissed = ModalRoute.of(context)?.isCurrent != true;
    if (!isDismissed) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always) {
        await LocationDialog.showLocationDialog(context);
      }
    }
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      print("no user data");
      return false;
    }

    final extractedUserData =
        Map<String, dynamic>.from(json.decode(pref.getString('userData')!));

    final expiryDate =
        DateTime.parse(extractedUserData['expiryDate'].toString());
    print(expiryDate);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    _userEmail = extractedUserData['userEmail'].toString();
    _expiryDate = expiryDate;
    notifyListeners();
    return true;
  }

  Future<void> authentication(String email, String password) async {
    try {
      final url = '$mainUrl/api/login';

      final response = await http.post(Uri.parse(url),
          body: json.encode({'email': email, 'password': password}),
          headers: {
            "Content-Type": "application/json",
          });

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      print(responseData['user']['id'].runtimeType);
      _token = responseData['access_token'];
      _userId = responseData['user']['id'];
      _userEmail = responseData['user']['email'];

      _expiryDate = DateTime.now()
          .add(Duration(seconds: responseData['user']['expiresIn']));

      _autoLogout();
      notifyListeners();

      final pref = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userEmail': _userEmail,
        'expiryDate': _expiryDate!.toIso8601String(),
      });

      await pref.setString('userData', userData);

      // print('check' + userData.toString());
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(String email, String password) {
    return authentication(email, password);
  }

  Future<void> signUp(String email, String password) {
    return authentication(email, password);
  }
}
