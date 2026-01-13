import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  static final NotificationService _notificationService =
      NotificationService._internal();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const Map<NotificationType, int> _notificationIds = {
    NotificationType.dailyReminder: 1,
    NotificationType.weeklyProgress: 2,
    NotificationType.motivationalReminder: 3,
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

  /// Check if notifications are enabled
  Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
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

  // Schedule a notification based on type, frequency, and preferred time
  Future<void> scheduleNotification({
    required NotificationType type,
    required NotificationFrequency frequency,
    TimeOfDay? preferredTime,
    String? customMessage,
  }) async {
    // Cancel existing notifications for this type
    await cancelNotificationsForType(type);

    if (frequency == NotificationFrequency.never) {
      return;
    }

    final notificationId = _notificationIds[type]!;
    final time = preferredTime ?? const TimeOfDay(hour: 9, minute: 0);

    // Calculate next notification time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past, move to next occurrence
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        Duration(days: frequency.daysInterval ?? 1),
      );
    }

    final androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: _getChannelDescription(type),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      _getNotificationTitle(type, customMessage),
      _getNotificationBody(type),
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getMatchDateTimeComponents(frequency),
    );
  }

  /// Cancel notifications for a specific type
  Future<void> cancelNotificationsForType(NotificationType type) async {
    final notificationId = _notificationIds[type];
    if (notificationId != null) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// Opens the settings to allow notifications
  Future<void> openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  Future<void> cancelTimerEnd() async {
    await flutterLocalNotificationsPlugin.cancel(999);
  }

  // Helper methods
  String _getNotificationTitle(NotificationType type, [String? customMessage]) {
    switch (type) {
      case NotificationType.dailyReminder:
        return 'Zeit zum Lernen! 📚';
      case NotificationType.weeklyProgress:
        return 'Dein Wochenfortschritt 📍';
      case NotificationType.motivationalReminder:
        return customMessage ?? 'Bleib dran und gib alles! 🔥';
    }
  }

  String _getNotificationBody(NotificationType type) {
    switch (type) {
      case NotificationType.dailyReminder:
        return 'Vergiss nicht, heute deine Lerneinheit zu absolvieren!';
      case NotificationType.weeklyProgress:
        return 'Schau dir an, wie weit du diese Woche gekommen bist!';
      case NotificationType.motivationalReminder:
        return '';
    }
  }

  String _getChannelDescription(NotificationType type) {
    switch (type) {
      case NotificationType.dailyReminder:
        return 'Daily learning reminders';
      case NotificationType.weeklyProgress:
        return 'Weekly progress summaries';
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
      case NotificationFrequency.everyOtherDay:
      case NotificationFrequency.never:
        return null; // Handle manually with rescheduling
    }
  }
}
