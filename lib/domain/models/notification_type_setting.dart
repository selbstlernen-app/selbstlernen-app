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
  // Custom motivational message
  motivationalReminder,

  // Session custom
  sessionReminder;

  String get displayName {
    switch (this) {
      case NotificationType.motivationalReminder:
        return 'Motivierende Erinnerung';
      case NotificationType.sessionReminder:
        return 'Lerneinheit Erinnerung';
    }
  }

  String get description {
    switch (this) {
      case NotificationType.motivationalReminder:
        return 'Motiviere mich, meine Ziele weiterhin zu verfolgen';
      case NotificationType.sessionReminder:
        return 'Erinnere mich zu den Zeitpunkten, an denen ich die Lerneinheit durchführen möchte';
    }
  }
}

/// Notification frequency options
enum NotificationFrequency {
  daily,

  weekly;

  String get displayName {
    switch (this) {
      case NotificationFrequency.daily:
        return 'Täglich';
      case NotificationFrequency.weekly:
        return 'Wöchentlich';
    }
  }

  int? get daysInterval {
    switch (this) {
      case NotificationFrequency.daily:
        return 1;
      case NotificationFrequency.weekly:
        return 7;
    }
  }
}
