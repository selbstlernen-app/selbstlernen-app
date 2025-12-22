import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_type_setting.freezed.dart';

@freezed
abstract class NotificationTypeSetting with _$NotificationTypeSetting {
  const factory NotificationTypeSetting({
    required NotificationType type,
    required NotificationFrequency frequency,
    required bool enabled,
    TimeOfDay? preferredTime,
    String? customMessage,
  }) = _NotificationTypeSetting;
}

/// Types of notifications
enum NotificationType {
  // Daily reminder to keep up
  dailyReminder,
  // Weekly reminder about current progress; generally
  weeklyProgress,
  // Custom motivational message
  motivationalReminder;

  String get displayName {
    switch (this) {
      case NotificationType.dailyReminder:
        return 'Tägliche Erinnerung';
      case NotificationType.weeklyProgress:
        return 'Wöchentlicher Fortschritt';
      case NotificationType.motivationalReminder:
        return 'Motivierende Erinnerung';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.dailyReminder:
        return 'Erinnere mich an meine tägliche Lerneinheit';
      case NotificationType.weeklyProgress:
        return 'Zeige mir meinen Wochenfortschritt';
      case NotificationType.motivationalReminder:
        return 'Motiviere mich, meine Ziele weiterhin zu verfolgen';
    }
  }
}

/// Notification frequency options
enum NotificationFrequency {
  never,
  daily,
  everyOtherDay,
  weekly,
  biweekly;

  String get displayName {
    switch (this) {
      case NotificationFrequency.never:
        return 'Nie';
      case NotificationFrequency.daily:
        return 'Täglich';
      case NotificationFrequency.everyOtherDay:
        return 'Jeden 2. Tag';
      case NotificationFrequency.weekly:
        return 'Wöchentlich';
      case NotificationFrequency.biweekly:
        return 'Alle 2 Wochen';
    }
  }

  int? get daysInterval {
    switch (this) {
      case NotificationFrequency.never:
        return null;
      case NotificationFrequency.daily:
        return 1;
      case NotificationFrequency.everyOtherDay:
        return 2;
      case NotificationFrequency.weekly:
        return 7;
      case NotificationFrequency.biweekly:
        return 14;
    }
  }
}
