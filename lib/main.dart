import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rest_api_login/background_fetch_location/background_methods.dart';
import 'package:rest_api_login/providers/auth.dart';
import 'package:rest_api_login/screens/home_Screen.dart';
import 'package:rest_api_login/screens/login_Screen.dart';
import 'package:rest_api_login/screens/splash_Screen.dart';

void main() {
  runApp(MyApp());
  BackgroundMethods.init();
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    BackgroundMethods.initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Auth()..tryAutoLogin(),
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'Mz solution tracking',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          //auth.isAuth it coming from auth.dart
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : LoginScreen(),
                ),
        ),
      ),
    );
  }
}
