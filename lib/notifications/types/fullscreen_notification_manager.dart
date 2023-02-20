import 'dart:developer';
import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/android_foreground_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clock_app/alarm/data/alarm_notification_channel.dart';
import 'package:clock_app/alarm/logic/alarm_controls.dart';
import 'package:clock_app/alarm/logic/schedule_alarm.dart';
import 'package:clock_app/common/logic/lock_screen_flags.dart';
import 'package:clock_app/common/utils/time_of_day.dart';
import 'package:clock_app/main.dart';
import 'package:clock_app/navigation/types/app_visibility.dart';
import 'package:clock_app/navigation/types/routes.dart';
import 'package:clock_app/settings/types/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:move_to_background/move_to_background.dart';

class FullScreenNotificationData {
  int id;
  final String title;
  final Map<String, String?>? payload;
  final String snoozeActionLabel;
  final String dismissActionLabel;
  final String route;

  FullScreenNotificationData({
    required this.id,
    required this.title,
    this.payload,
    required this.snoozeActionLabel,
    required this.dismissActionLabel,
    required this.route,
  });
}

Map<AlarmType, FullScreenNotificationData> alarmNotificationData = {
  AlarmType.alarm: FullScreenNotificationData(
    id: 0,
    title: "Alarm Ringing",
    snoozeActionLabel: "Snooze",
    dismissActionLabel: "Dismiss",
    route: Routes.alarmNotificationRoute,
  ),
  AlarmType.timer: FullScreenNotificationData(
    id: 1,
    title: "Time's Up",
    snoozeActionLabel: "Add 1 Minute",
    dismissActionLabel: "Stop",
    route: Routes.timerNotificationRoute,
  ),
};

class AlarmNotificationManager {
  static const String _snoozeActionKey = "snooze";
  static const String _dismissActionKey = "dismiss";

  static FGBGType _fgbgType = FGBGType.foreground;

  static void showFullScreenNotification(
    AlarmType type,
    int scheduleId,
    String body,
  ) {
    FullScreenNotificationData data = alarmNotificationData[type]!;
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: data.id,
        channelKey: alarmNotificationChannelKey,
        title: data.title,
        body: body,
        payload: {
          "scheduleId": scheduleId.toString(),
          "type": type.toString(),
        },
        category: NotificationCategory.Alarm,
        fullScreenIntent: true,
        autoDismissible: false,
        wakeUpScreen: true,
        locked: true,
      ),
      actionButtons: [
        NotificationActionButton(
          showInCompactView: true,
          key: _snoozeActionKey,
          label: data.snoozeActionLabel,
          actionType: ActionType.SilentAction,
          autoDismissible: true,
        ),
        NotificationActionButton(
          showInCompactView: true,
          key: _dismissActionKey,
          label: data.dismissActionLabel,
          actionType: ActionType.SilentAction,
          autoDismissible: true,
        ),
      ],
    );
  }

  static Future<void> removeNotification(AlarmType type) async {
    FullScreenNotificationData data = alarmNotificationData[type]!;

    await AwesomeNotifications().cancel(data.id);
    await AndroidForegroundService.stopForeground(data.id);
  }

  static Future<void> closeNotification(AlarmType type) async {
    await removeNotification(type);

    await SettingsManager.initialize();
    await LockScreenFlagManager.clearLockScreenFlags();

    FullScreenNotificationData data = alarmNotificationData[type]!;

    if (Routes.currentRoute == data.route) {
      App.navigatorKey.currentState?.pop();
      Routes.setCurrentRoute(Routes.rootRoute);
    }

    if (_fgbgType == FGBGType.background &&
        AppVisibilityListener.state == FGBGType.foreground) {
      MoveToBackground.moveTaskToBack();
    }

    SettingsManager.preferences
        ?.setBool("fullScreenNotificationRecentlyShown", false);
  }

  static Future<void> snoozeAlarm(int scheduleId, AlarmType type) async {
    scheduleStopAlarm(scheduleId, AlarmStopAction.snooze, type: type);
    closeNotification(type);
  }

  static Future<void> dismissAlarm(int scheduleId, AlarmType type) async {
    scheduleStopAlarm(scheduleId, AlarmStopAction.dismiss, type: type);
    closeNotification(type);
  }

  static void handleNotificationCreated(
      ReceivedNotification receivedNotification) {
    _fgbgType = AppVisibilityListener.state;
    SettingsManager.preferences
        ?.setBool("fullScreenNotificationRecentlyShown", false);
  }

  static Future<void> handleNotificationAction(
      ReceivedAction receivedAction) async {
    int notificationId =
        int.parse(receivedAction.payload?['notificationId'] ?? "0");
    AlarmType type = AlarmType.values.firstWhere(
        (element) => element.toString() == receivedAction.payload?['type']);

    FullScreenNotificationData data = alarmNotificationData[type]!;

    switch (receivedAction.buttonKeyPressed) {
      case _snoozeActionKey:
        int scheduleId =
            int.parse(receivedAction.payload?['scheduleId'] ?? "0");
        snoozeAlarm(scheduleId, type);
        break;

      case _dismissActionKey:
        int scheduleId =
            int.parse(receivedAction.payload?['scheduleId'] ?? "0");
        dismissAlarm(scheduleId, type);
        break;

      default:
        await LockScreenFlagManager.setLockScreenFlags();
        if (Routes.currentRoute == data.route) {
          App.navigatorKey.currentState?.pop();
        }
        App.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          data.route,
          (route) {
            return (route.settings.name != data.route) || route.isFirst;
          },
          arguments: receivedAction,
        );
        break;
    }
  }
}