import 'package:flutter/foundation.dart';
import 'package:flutter_show_when_locked/flutter_show_when_locked.dart';

class ShowWhenLocked {
  static Future<void> hide() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FlutterShowWhenLocked().hide();
    } else {}
  }

  static Future<void> show() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await FlutterShowWhenLocked().show();
    } else {}
  }
}
