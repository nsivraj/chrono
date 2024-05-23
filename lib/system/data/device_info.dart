import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

AndroidDeviceInfo? _androidInfo;
IosDeviceInfo? _iosInfo;
LocalDeviceInfo? deviceInfo;

Future<void> initializeAndroidInfo() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    _androidInfo = await deviceInfo.androidInfo;
  }
}

Future<void> initializeiOSInfo() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    _iosInfo = await deviceInfo.iosInfo;
  }
}

Future<void> initializeDeviceInfo() async {
  await initializeAndroidInfo();
  await initializeiOSInfo();
  deviceInfo = LocalDeviceInfo();
}

class LocalDeviceInfo {
  late BuildVersion version;

  LocalDeviceInfo() {
    version = _androidInfo == null
        ? BuildVersion(34)
        : BuildVersion(_androidInfo!.version.sdkInt);
  }
}

class BuildVersion {
  final int sdkInt;

  BuildVersion(this.sdkInt);
}
