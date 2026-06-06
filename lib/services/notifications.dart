import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/plan_data.dart';

/// The "force" engine — schedules a brutal reminder for every block in the
/// daily timeline. No-ops on web (notifications handled by the browser layer).
class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'rebuild_schedule',
      'Rebuild Schedule',
      channelDescription: 'Daily timeline reminders for the 21-day rebuild',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  /// Brutal one-liners paired to each block.
  static String _push(ScheduleBlock b) {
    switch (b.label) {
      case 'WAKE':
        return 'UP. 05:30. The soft version of you does not get to decide.';
      case 'WALK':
        return 'Walk now. 45 min. No phone. Move or stay stuck.';
      case 'DEEP WORK 1':
        return 'Deep work. Hardest task first. 2 hrs, no excuses.';
      case 'MONEY BLOCK':
        return '5 proposals + 10 DMs. This is rent. Fire them NOW.';
      case 'TRAIN':
        return 'Hit the bag. A soft body builds a soft mind.';
      case 'REPORT':
        return 'Report the day. Honest. The chain cannot break.';
      case 'SLEEP':
        return '21:30. Shut it down. Tomorrow is won tonight.';
      default:
        return b.detail;
    }
  }

  static Future<void> scheduleDaily(int dayNumber) async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancelAll();
    for (var i = 0; i < PlanData.schedule.length; i++) {
      final b = PlanData.schedule[i];
      await _plugin.zonedSchedule(
        i,
        '${b.label} — Day $dayNumber',
        _push(b),
        _nextInstanceOf(b.hour, b.minute),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  static Future<void> cancelAll() async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancelAll();
  }

  static Future<void> buzz(String title, String body) async {
    if (kIsWeb || !_ready) return;
    await _plugin.show(999, title, body, _details);
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
