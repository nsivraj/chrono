import 'package:clock_app/alarm/types/alarm.dart';
import 'package:clock_app/clock/logic/initialize_default_favorite_cities.dart';
import 'package:clock_app/common/utils/list_storage.dart';
import 'package:clock_app/settings/data/settings_schema.dart';
import 'package:clock_app/stopwatch/types/stopwatch.dart';
import 'package:clock_app/timer/logic/initialize_default_timer_presets.dart';
import 'package:clock_app/timer/types/timer.dart';
import 'package:get_storage/get_storage.dart';

Future<void> _clearSettings() async {
  List<ClockTimer> timers = await loadList<ClockTimer>('timers');
  List<Alarm> alarms = await loadList<Alarm>('alarms');
  for (var alarm in alarms) {
    alarm.cancel();
  }
  for (var timer in timers) {
    timer.reset();
  }
  await GetStorage().erase();
}

Future<void> initializeSettings() async {
  // await SettingsManager.initialize();
  await GetStorage.init();

  // // Used to clear the preferences in case of a change in format of the data
  // // Comment this out after the preferences are cleared
  await _clearSettings();

  bool? firstLaunch = GetStorage().read('first_launch');
  if (firstLaunch == null) {
    GetStorage().write('first_launch', true);

    initializeDefaultFavoriteCities();
    initializeDefaultTimerPresets();
    saveList<Alarm>('alarms', []);
    saveList<ClockTimer>('timers', []);
    saveList<ClockStopwatch>('stopwatches', [ClockStopwatch()]);
    appSettings.save("settings");
  }

  appSettings.load("settings");
}
