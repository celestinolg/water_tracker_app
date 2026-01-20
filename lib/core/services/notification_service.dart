import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1;
  static const String _channelId = 'water_tracker_reminders';
  static const String _channelName = 'Water Reminders';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> schedulePeriodicReminders({
    required int intervalHours,
    required int wakeHour,
    required int sleepHour,
    required String title,
    required String body,
  }) async {
    await cancelAllReminders();

    final now = DateTime.now();

    // Schedule reminders from wake hour to sleep hour
    for (int hour = wakeHour; hour < sleepHour; hour += intervalHours) {
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        0,
        0,
      );

      // Skip past times
      if (scheduledTime.isBefore(now)) continue;

      try {
        await _scheduleNotification(
          id: _reminderId + hour,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
        );
      } catch (e) {
        // Gracefully ignore scheduling errors (e.g. exact_alarms_not_permitted)
        debugPrint('NotificationService: failed to schedule at $hour:00 — $e');
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Hydration reminders to drink water',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showGoalReachedNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Goal reached notification',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(999, title, body, notifDetails);
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}
