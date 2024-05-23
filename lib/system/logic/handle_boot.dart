import 'package:clock_app/alarm/logic/update_alarms.dart';
import 'package:clock_app/system/logic/initialize_isolate.dart';
import 'package:clock_app/timer/logic/update_timers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boot_receiver/flutter_boot_receiver.dart';

@pragma('vm:entry-point')
void handleBoot() async {
  // String appDataDirectory = await getAppDataDirectoryPath();
  //
  // String message = '[${DateTime.now().toString()}] Test2\n';
  //
  // File('$appDataDirectory/log-dart.txt')
  //     .writeAsStringSync(message, mode: FileMode.append);
  //
  await initializeIsolate();

  await updateAlarms("handleBoot(): Update alarms on system boot");
  await updateTimers("handleBoot(): Update timers on system boot");
}

class BootHandler {
  static Future<void> initialize(void Function() handleBoot) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await BootReceiver.initialize(handleBoot);
    } else {
      handleBoot();
    }
  }
}
