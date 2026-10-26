import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return; // local notifications are mobile-only
    tzdata.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Cancels old reminders and schedules: 1 day before and 1 hour before each event.
  static Future<void> reschedule(List<Map<String, dynamic>> events) async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
    final now = DateTime.now();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule',
        'Schedule reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    for (final e in events) {
      final when = e['dateTime'] as DateTime;
      final base = (e['id'] as String).hashCode.abs() % 1000000 * 2;
      final reminders = {
        base: [when.subtract(const Duration(days: 1)), 'Tomorrow'],
        base + 1: [when.subtract(const Duration(hours: 1)), 'In 1 hour'],
      };
      for (final entry in reminders.entries) {
        final at = entry.value[0] as DateTime;
        if (at.isBefore(now)) continue;
        await _plugin.zonedSchedule(
          id: entry.key,
          title: '${entry.value[1]}: ${e['title']}',
          body: 'Check the schedule for details',
          scheduledDate: tz.TZDateTime.from(at, tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}
