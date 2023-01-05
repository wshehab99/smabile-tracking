import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LocationDialog {
  static Future showLocationDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset("assets/json/location.json",
                  height: 200, width: 200),
              Text(
                "Please go to app settings > permission > location > choose always for better experience",
              ),
            ],
          ),
          actions: [
            ElevatedButton(
                onPressed: () async {
                  await AppSettings.openAppSettings().then((value) {
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Location settings"))
          ],
        ),
      );
    });
  }
}
