import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:clock_app/common/types/json.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
    // switch (task) {
    //   case Workmanager.iOSBackgroundTask:
    //     print("The iOS background fetch was triggered");
    //     break;
    // }
    return Future.value(true);
  });
}

// @pragma(
//     'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case simpleTaskKey:
//         print("$simpleTaskKey was executed. inputData = $inputData");
//         final prefs = await SharedPreferences.getInstance();
//         prefs.setBool("test", true);
//         print("Bool from prefs: ${prefs.getBool("test")}");
//         break;
//       case rescheduledTaskKey:
//         final key = inputData!['key']!;
//         final prefs = await SharedPreferences.getInstance();
//         if (prefs.containsKey('unique-$key')) {
//           print('has been running before, task is successful');
//           return true;
//         } else {
//           await prefs.setBool('unique-$key', true);
//           print('reschedule task');
//           return false;
//         }
//       case failedTaskKey:
//         print('failed task');
//         return Future.error('failed');
//       case simpleDelayedTask:
//         print("$simpleDelayedTask was executed");
//         break;
//       case simplePeriodicTask:
//         print("$simplePeriodicTask was executed");
//         break;
//       case simplePeriodic1HourTask:
//         print("$simplePeriodic1HourTask was executed");
//         break;
//       case Workmanager.iOSBackgroundTask:
//         print("The iOS background fetch was triggered");
//         Directory? tempDir = await getTemporaryDirectory();
//         String? tempPath = tempDir.path;
//         print(
//             "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
//         break;
//     }

//     return Future.value(true);
//   });
// }

class AlarmManager {
  static Future<bool> initialize() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await AndroidAlarmManager.initialize();
    } else {
      await Workmanager().initialize(
          callbackDispatcher, // The top level function, aka callbackDispatcher
          isInDebugMode:
              true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );
      return true;
    }
  }

  static Future<bool> cancel(String scheduleId) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await AndroidAlarmManager.cancel(int.parse(scheduleId));
    } else {
      // await Workmanager().cancelByTag(scheduleId);
      await Workmanager().cancelByUniqueName(scheduleId);
      return true;
    }
  }

  static Future<bool> oneShotAt(DateTime startDate, int scheduleId,
      void Function(int scheduleId, Json? params) triggerScheduledNotification,
      {required bool allowWhileIdle,
      required bool alarmClock,
      required bool exact,
      required bool wakeup,
      required bool rescheduleOnReboot,
      required Map<String, String> params}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await AndroidAlarmManager.oneShotAt(
        startDate,
        scheduleId,
        triggerScheduledNotification,
        allowWhileIdle: allowWhileIdle,
        alarmClock: alarmClock,
        exact: exact,
        wakeup: wakeup,
        rescheduleOnReboot: rescheduleOnReboot,
        params: params,
      );
    } else {
      // await Workmanager().registerOneOffTask
      String scheduleIdStr = scheduleId.toString();

      await Workmanager().registerOneOffTask(
        scheduleIdStr,
        scheduleIdStr,
        inputData: {
          'startDate': startDate.toUtc().millisecondsSinceEpoch,
          'scheduleId': scheduleIdStr,
          // 'triggerScheduledNotification': triggerScheduledNotification,
          'allowWhileIdle': allowWhileIdle,
          'alarmClock': alarmClock,
          'exact': exact,
          'wakeup': wakeup,
          'rescheduleOnReboot': rescheduleOnReboot,
          // 'params': params
        },
      );
      return true;
    }
  }
}
