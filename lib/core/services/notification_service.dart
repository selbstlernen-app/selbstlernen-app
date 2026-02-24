import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  static final NotificationService _notificationService =
      NotificationService._internal();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const Map<NotificationType, int> _notificationIds = {
    NotificationType.motivationalReminder: 1,
    NotificationType.dailyReminder: 2,
  };

  Future<void> init() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation('Europe/Berlin'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();

    // For Android 13+, specifically need to check for exact alarms
    if (Platform.isAndroid) {
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      if (alarmStatus.isDenied) {
        await openNotificationSettings();
      }
    }

    return status.isGranted;
  }

  int _getUniqueId(int sessionId, int dayOfWeek) {
    return sessionId * 10 + dayOfWeek;
  }

  // Gets all possible ids for a session needed for scheduling/cancelling
  List<int> _getAllPossibleIds(int sessionId) {
    return List.generate(8, (index) => sessionId * 10 + index);
  }

  Future<void> cancelSpecificSessionNotifications(int sessionId) async {
    final ids = _getAllPossibleIds(sessionId);
    for (final id in ids) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  Future<void> _scheduleSingleSession(
    int sessionId,
    String sessionTitle,
    TimeOfDay plannedTime,
  ) async {
    final scheduledDate = _calculateNextInstance(plannedTime);
    await _executeSchedule(
      id: sessionId * 10,
      title: _getNotificationTitle(NotificationType.sessionReminder),
      body: _getNotificationBody(
        NotificationType.sessionReminder,
        sessionTitle,
      ),
      scheduledDate: scheduledDate,
      type: NotificationType.sessionReminder,
      matchComponents: null,
    );
  }

  Future<void> _scheduleWeeklySessions(
    int sessionId,
    String title,
    TimeOfDay time,
    List<int> days,
    DateTime start,
    DateTime end,
  ) async {
    for (final dayOfWeek in days) {
      final scheduledDate = _nextInstanceOfDayAndTime(dayOfWeek, time, start);

      if (scheduledDate.isAfter(tz.TZDateTime.from(end, tz.local))) {
        continue;
      }

      await _executeSchedule(
        id: _getUniqueId(sessionId, dayOfWeek),
        title: _getNotificationTitle(NotificationType.sessionReminder),
        body: _getNotificationBody(NotificationType.sessionReminder, title),
        scheduledDate: scheduledDate,
        type: NotificationType.sessionReminder,
        matchComponents: _getMatchDateTimeComponents(
          NotificationFrequency.weekly,
        ),
      );
    }
  }

  tz.TZDateTime _calculateNextInstance(
    TimeOfDay time, [
    int? daysInterval = 1,
  ]) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(Duration(days: daysInterval ?? 1));
    }
    return scheduled;
  }

  // If the session is repeating; then set type to fit frequency
  // Else repeat as long as session has not been archived yet
  Future<void> scheduleSessionNotification({
    required int sessionId,
    required bool hasNotification,
    required bool isRepeating,
    required TimeOfDay plannedTime,
    required String sessionTitle,
    List<int>? selectedDays,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Cancel any specific session notifications
    await cancelSpecificSessionNotifications(sessionId);

    if (!hasNotification) return;

    if (!isRepeating) {
      await _scheduleSingleSession(sessionId, sessionTitle, plannedTime);
    } else {
      // For repeating sessions we can assume that selectedDays, start
      // and end date are given
      await _scheduleWeeklySessions(
        sessionId,
        sessionTitle,
        plannedTime,
        selectedDays!,
        startDate!,
        endDate!,
      );
    }
  }

  // Schedule a notification based on type, frequency, and preferred time
  Future<void> scheduleNotification({
    required NotificationType type,
    required NotificationFrequency frequency,
    TimeOfDay? preferredTime,
    String? customMessage,
  }) async {
    // Cancel existing notifications for this type
    await cancelNotificationsForType(type);

    final notificationId = _notificationIds[type]!;
    final time = preferredTime ?? const TimeOfDay(hour: 9, minute: 0);

    final scheduledDate = _calculateNextInstance(
      time,
      frequency.daysInterval,
    );

    await _executeSchedule(
      id: notificationId,
      title: _getNotificationTitle(type, customMessage),
      body: _getNotificationBody(type),
      scheduledDate: scheduledDate,
      type: type,
      matchComponents: _getMatchDateTimeComponents(frequency),
    );
  }

  /// Cancel notifications for a specific type
  Future<void> cancelNotificationsForType(NotificationType type) async {
    final notificationId = _notificationIds[type];
    if (notificationId != null) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  /// Function to check what notifications are pending; for debugging
  Future<void> pendingNotifications() async {
    final notificiations = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    for (final note in notificiations) {
      print(note.id);
      print(note.title);
      print(note.body);
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Opens the settings to allow notifications
  Future<void> openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  /// Execute the scheduled notification
  Future<void> _executeSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationType type,
    required DateTimeComponents? matchComponents,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: _getChannelDescription(type),
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
    );
  }

  // -- Helper methods --
  String _getNotificationTitle(NotificationType type, [String? customMessage]) {
    switch (type) {
      case NotificationType.dailyReminder:
        return 'Zeit zu lernen! ⏰';
      case NotificationType.sessionReminder:
        return 'Zeit zu arbeiten! 🎯';
      case NotificationType.motivationalReminder:
        return customMessage ?? 'Bleib dran und gib alles! 🔥';
    }
  }

  String _getNotificationBody(NotificationType type, [String? customMessage]) {
    switch (type) {
      case NotificationType.dailyReminder:
        return 'Vergiss nicht, deine Lerneinheiten für heute abzuschließen!';
      case NotificationType.sessionReminder:
        return 'Deine Einheit "$customMessage" wartet auf dich';
      case NotificationType.motivationalReminder:
        return '';
    }
  }

  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.dailyReminder:
        return 'Daily reminder';
      case NotificationType.sessionReminder:
        return 'Session specific reminder';
      case NotificationType.motivationalReminder:
        return 'Motivational reminders';
    }
  }

  DateTimeComponents? _getMatchDateTimeComponents(
    NotificationFrequency frequency,
  ) {
    switch (frequency) {
      case NotificationFrequency.daily:
        return DateTimeComponents.time; // Same time every day
      case NotificationFrequency.weekly:
        return DateTimeComponents
            .dayOfWeekAndTime; // Same day and time every week
    }
  }

  /// Get the next scheduled date when the notification is supposed to appear
  tz.TZDateTime _nextInstanceOfDayAndTime(
    int dayOfWeek,
    TimeOfDay plannedTime,
    DateTime startDate,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      startDate.year,
      startDate.month,
      startDate.day,
      plannedTime.hour,
      plannedTime.minute,
    );

    while ((scheduledDate.weekday - 1) != dayOfWeek ||
        scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
