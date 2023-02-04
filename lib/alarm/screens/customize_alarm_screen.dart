import 'package:clock_app/alarm/logic/alarm_description.dart';
import 'package:clock_app/alarm/types/alarm.dart';
import 'package:clock_app/common/utils/time_of_day.dart';
import 'package:clock_app/common/widgets/clock_display.dart';
import 'package:clock_app/common/widgets/time_picker.dart';
import 'package:clock_app/navigation/types/alignment.dart';
import 'package:clock_app/settings/data/settings_data.dart';
import 'package:clock_app/settings/logic/get_setting_widget.dart';
import 'package:clock_app/theme/color.dart';
import 'package:flutter/material.dart';

class CustomizeAlarmScreen extends StatefulWidget {
  const CustomizeAlarmScreen({
    super.key,
    required this.initialAlarm,
  });

  final Alarm initialAlarm;

  @override
  State<CustomizeAlarmScreen> createState() => _CustomizeAlarmScreenState();
}

class _CustomizeAlarmScreenState extends State<CustomizeAlarmScreen> {
  late Alarm _alarm;
  int lastPlayedRingtoneIndex = -1;

  @override
  void initState() {
    super.initState();
    _alarm = Alarm.fromAlarm(widget.initialAlarm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title:
        //     Text('Add Alarm', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context, _alarm);
              },
              child: const Text("Save"))
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: [
                  GestureDetector(
                    child: ClockDisplay(
                      dateTime: _alarm.timeOfDay.toDateTime(),
                      horizontalAlignment: ElementAlignment.center,
                    ),
                    onTap: () async {
                      TimePickerResult? timePickerResult =
                          await showTimePickerDialog(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: "Select Time",
                        cancelText: "Cancel",
                        confirmText: "Save",
                      );

                      if (timePickerResult != null) {
                        setState(() {
                          _alarm.setTimeOfDay(timePickerResult.timeOfDay);
                        });
                      }
                    },
                  ),
                  Text(
                    getAlarmDescriptionText(_alarm),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: ColorTheme.textColorTertiary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...getSettingWidgets(
              _alarm.settings,
              onChanged: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}