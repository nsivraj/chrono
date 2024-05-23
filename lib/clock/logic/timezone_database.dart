import 'dart:io';

import 'package:flutter/services.dart';

import 'package:clock_app/common/data/paths.dart';
// Database? database;

Future<void> initializeDatabases() async {
  String timezonesDatabasePath = await getTimezonesDatabasePath();

  File tzDBPath = File(timezonesDatabasePath);
  while (!tzDBPath.parent.existsSync()) {
    print("Waiting for path $timezonesDatabasePath to exist!!");
    // sleep(Duration(seconds: 3));
    await Future.delayed(const Duration(milliseconds: 3000), () {
      return true;
    });
  }

  // Only copy if the database doesn't exist
  if (FileSystemEntity.typeSync(timezonesDatabasePath) ==
      FileSystemEntityType.notFound) {
    // Load database from asset and copy
    ByteData data = await rootBundle.load('assets/timezones.db');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await File(timezonesDatabasePath).writeAsBytes(bytes);
  }
}
