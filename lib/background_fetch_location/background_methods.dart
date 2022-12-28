import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rest_api_login/background_fetch_location/send_location.dart';

import '../utils/geo_location.dart';

class BackgroundMethods {
// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
  @pragma('vm:entry-point')
  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      // This task has exceeded its allowed running-time.
      // You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] Headless task timed-out: $taskId");
      BackgroundFetch.finish(taskId);
      return;
    }
    print('[BackgroundFetch] Headless event received.');
    // Do your work here...
    BackgroundFetch.finish(taskId);
  }

  static init() {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  static Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless:
            true, //for run the method even when os terminated the app
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        forceAlarmManager: true,
        requiredNetworkType: NetworkType.ANY,
      ),
      onFetch,
      onTimeout,
    );
    print('[BackgroundFetch] configure success: $status');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  static Future onFetch(String taskId) async {
    // <-- Event handler
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received $taskId");
    switch (taskId) {
      case 'com.transistorSoft.customTask':
        scheduleTask();
        break;
      default:
        final Position position = await LocationServices().determinePosition();

        print("location fetched $position");
    }
    await SendLocation.sendLocation();
    // IMPORTANT:  You must signal completion of your task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  static Future onTimeout(String taskId) async {
    // <-- Task timeout handler.
    // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
    BackgroundFetch.finish(taskId);
  }

  static void scheduleTask() async {
    await BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorSoft.customTask",
      delay: 60000, // milliseconds
      stopOnTerminate: false,
      periodic: true, requiresCharging: false,
    ));
    final Position position = await LocationServices().determinePosition();

    print("location fetched customTask $position");
  }
}
