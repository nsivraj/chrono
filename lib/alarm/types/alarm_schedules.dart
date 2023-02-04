import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:clock_app/alarm/logic/handle_alarm_trigger.dart';
import 'package:clock_app/alarm/logic/alarm_time.dart';
import 'package:clock_app/alarm/types/alarm_runner.dart';
import 'package:clock_app/alarm/types/schedule_type.dart';
import 'package:clock_app/common/utils/json_serialize.dart';
import 'package:clock_app/common/utils/time_of_day.dart';
import 'package:clock_app/settings/types/setting.dart';
import 'package:clock_app/settings/types/settings.dart';
import 'package:flutter/material.dart';

class WeekdaySchedule extends JsonSerializable {
  int weekday;
  AlarmRunner alarmRunner;

  WeekdaySchedule(this.weekday) : alarmRunner = AlarmRunner();

  WeekdaySchedule.fromJson(Map<String, dynamic> json)
      : weekday = json['weekday'],
        alarmRunner = AlarmRunner.fromJson(json['alarmRunner']);

  @override
  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'alarmRunner': alarmRunner.toJson(),
      };
}

class DateSchedule extends JsonSerializable {
  DateTime date;
  AlarmRunner alarmRunner;

  DateSchedule(this.date) : alarmRunner = AlarmRunner();

  DateSchedule.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        alarmRunner = AlarmRunner.fromJson(json['alarmRunner']);

  @override
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'alarmRunner': alarmRunner.toJson(),
      };
}

abstract class AlarmSchedule extends JsonSerializable {
  Settings alarmSettings;

  AlarmSchedule(this.alarmSettings);

  List<AlarmRunner> get alarmRunners;
  void schedule(TimeOfDay timeOfDay, int ringtoneIndex);
  void cancel();
  bool hasId(int id);
}

class OnceAlarmSchedule extends AlarmSchedule {
  late final AlarmRunner _alarmRunner;

  OnceAlarmSchedule(Settings alarmSettings)
      : _alarmRunner = AlarmRunner(),
        super(alarmSettings);

  @override
  void schedule(TimeOfDay timeOfDay, int ringtoneIndex) {
    DateTime alarmDate = getDailyAlarmDate(timeOfDay);
    _alarmRunner.schedule(alarmDate, ringtoneIndex);
  }

  @override
  void cancel() {
    _alarmRunner.cancel();
  }

  @override
  toJson() => {
        'alarmRunner': _alarmRunner.toJson(),
      };

  OnceAlarmSchedule.fromJson(Map<String, dynamic> json, Settings alarmSettings)
      : _alarmRunner = AlarmRunner.fromJson(json['alarmRunner']),
        super(alarmSettings);

  @override
  bool hasId(int id) {
    return _alarmRunner.id == id;
  }

  @override
  List<AlarmRunner> get alarmRunners => [_alarmRunner];
}

class DailyAlarmSchedule extends AlarmSchedule {
  late final AlarmRunner _alarmRunner;

  DailyAlarmSchedule(Settings alarmSettings)
      : _alarmRunner = AlarmRunner(),
        super(alarmSettings);

  @override
  void schedule(TimeOfDay timeOfDay, int ringtoneIndex) {
    DateTime alarmDate = getDailyAlarmDate(timeOfDay);
    _alarmRunner.schedule(alarmDate, ringtoneIndex,
        repeatInterval: const Duration(days: 1));
  }

  @override
  void cancel() {
    _alarmRunner.cancel();
  }

  @override
  toJson() => {
        'alarmRunner': _alarmRunner.toJson(),
      };

  DailyAlarmSchedule.fromJson(Map<String, dynamic> json, Settings alarmSettings)
      : _alarmRunner = AlarmRunner.fromJson(json['alarmRunner']),
        super(alarmSettings);

  @override
  bool hasId(int id) {
    return _alarmRunner.id == id;
  }

  @override
  List<AlarmRunner> get alarmRunners => [_alarmRunner];
}

class WeeklyAlarmSchedule extends AlarmSchedule {
  List<WeekdaySchedule> _weekdaySchedules = [];

  WeeklyAlarmSchedule(Settings alarmSettings) : super(alarmSettings);

  @override
  void schedule(TimeOfDay timeOfDay, int ringtoneIndex) {
    for (WeekdaySchedule weekdaySchedule in _weekdaySchedules) {
      weekdaySchedule.alarmRunner.cancel();
    }

    List<int> weekdays =
        (alarmSettings.getSetting("Week Days") as ToggleSetting<int>)
            .selected
            .toList();

    _weekdaySchedules =
        weekdays.map((weekday) => WeekdaySchedule(weekday)).toList();

    for (WeekdaySchedule weekdaySchedule in _weekdaySchedules) {
      DateTime alarmDate =
          getWeeklyAlarmDate(timeOfDay, weekdaySchedule.weekday);
      weekdaySchedule.alarmRunner.schedule(
        alarmDate,
        ringtoneIndex,
        repeatInterval: const Duration(days: 7),
      );
    }
  }

  @override
  void cancel() {
    for (WeekdaySchedule weekday in _weekdaySchedules) {
      weekday.alarmRunner.cancel();
    }
  }

  @override
  toJson() => {
        'weekdaySchedules': _weekdaySchedules.map((e) => e.toJson()).toList(),
      };

  WeeklyAlarmSchedule.fromJson(
      Map<String, dynamic> json, Settings alarmSettings)
      : _weekdaySchedules = (json['weekdaySchedules'] as List)
            .map((e) => WeekdaySchedule.fromJson(e))
            .toList(),
        super(alarmSettings);

  @override
  bool hasId(int id) {
    return _weekdaySchedules
        .any((weekdaySchedule) => weekdaySchedule.alarmRunner.id == id);
  }

  @override
  List<AlarmRunner> get alarmRunners =>
      _weekdaySchedules.map((e) => e.alarmRunner).toList();
}

/*
dropdown

- specific dates

these will reveal the range and off days option
- daily
- specific days of month
- specific days of week


- specific dates -> onetime

{
- daily -> periodic
- specific day of month -> 12 periodic with 1 year duration
- specific days of week -> periodic

range
 - start -> forever
 or
 - start -> end  -> list of onetime
}

- off-days  -> send off days as params, don't show notif if today is off day
*/

class DatesAlarmSchedule extends AlarmSchedule {
  List<DateSchedule> _dateSchedules = [];

  DatesAlarmSchedule(Settings alarmSettings) : super(alarmSettings);

  @override
  void cancel() {
    for (DateSchedule dateSchedule in _dateSchedules) {
      dateSchedule.alarmRunner.cancel();
    }
  }

  @override
  void schedule(TimeOfDay timeOfDay, int ringtoneIndex) {
    for (DateSchedule dateSchedule in _dateSchedules) {
      dateSchedule.alarmRunner.cancel();
    }

    for (DateSchedule dateSchedule in _dateSchedules) {
      DateTime alarmDate =
          getDailyAlarmDate(timeOfDay, scheduledDate: dateSchedule.date);
      dateSchedule.alarmRunner.schedule(alarmDate, ringtoneIndex);
    }
  }

  @override
  toJson() => {
        'dateSchedules': _dateSchedules.map((e) => e.toJson()).toList(),
      };

  DatesAlarmSchedule.fromJson(Map<String, dynamic> json, Settings alarmSettings)
      : _dateSchedules = (json['dateSchedules'] as List)
            .map((e) => DateSchedule.fromJson(e))
            .toList(),
        super(alarmSettings);

  @override
  bool hasId(int id) {
    return _dateSchedules
        .any((dateSchedule) => dateSchedule.alarmRunner.id == id);
  }

  @override
  List<AlarmRunner> get alarmRunners =>
      _dateSchedules.map((e) => e.alarmRunner).toList();
}

class RangeAlarmSchedule extends AlarmSchedule {
  late final AlarmRunner _alarmRunner;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  Duration _interval = const Duration(days: 1);

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  RangeAlarmSchedule(Settings alarmSettings)
      : _alarmRunner = AlarmRunner(),
        super(alarmSettings);

  @override
  void schedule(TimeOfDay timeOfDay, int ringtoneIndex) {
    DateTime alarmDate =
        getDailyAlarmDate(timeOfDay, scheduledDate: _startDate);
    _alarmRunner.schedule(alarmDate, ringtoneIndex, repeatInterval: _interval);
  }

  @override
  void cancel() {
    _alarmRunner.cancel();
  }

  @override
  toJson() => {
        'alarmRunner': _alarmRunner.toJson(),
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'interval': _interval.inMilliseconds,
      };

  RangeAlarmSchedule.fromJson(Map<String, dynamic> json, Settings alarmSettings)
      : _alarmRunner = AlarmRunner.fromJson(json['alarmRunner']),
        _startDate = DateTime.parse(json['startDate']),
        _endDate = DateTime.parse(json['endDate']),
        _interval = Duration(milliseconds: json['interval']),
        super(alarmSettings);

  @override
  bool hasId(int id) {
    return _alarmRunner.id == id;
  }

  @override
  List<AlarmRunner> get alarmRunners => [_alarmRunner];
}