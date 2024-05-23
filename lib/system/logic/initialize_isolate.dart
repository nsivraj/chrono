import 'dart:ui';

import 'package:clock_app/alarm/alarm_manager.dart';
import 'package:clock_app/audio/logic/audio_session.dart';
import 'package:clock_app/audio/types/ringtone_player.dart';
import 'package:clock_app/common/data/paths.dart';
import 'package:clock_app/notifications/logic/notifications.dart';
import 'package:clock_app/settings/logic/initialize_settings.dart';
import 'package:clock_app/system/data/device_info.dart';

Future<void> initializeIsolate() async {
  DartPluginRegistrant.ensureInitialized();
  await initializeDeviceInfo();
  await initializeAppDataDirectory();
  await initializeStorage(false);
  await initializeSettings();
  await initializeNotifications();
  await initializeAudioSession();
  await AlarmManager.initialize();
  await RingtonePlayer.initialize();
}
