import 'package:drift/drift.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';

extension NotificationToModelMapper on Notification {
  NotificationTypeSetting toDomain() {
    return NotificationTypeSetting(
      type: NotificationType.values.firstWhere(
        (e) => e.name == notificationType,
        orElse: () => NotificationType.dailyReminder,
      ),
      frequency: NotificationFrequency.values.firstWhere(
        (e) => e.name == frequency,
        orElse: () => NotificationFrequency.daily,
      ),
      enabled: enabled,
      preferredTime: preferredTimeHour != null && preferredTimeMinute != null
          ? TimeOfDay(hour: preferredTimeHour!, minute: preferredTimeMinute!)
          : null,
    );
  }

  static List<NotificationTypeSetting> mapFromListOfEntity(
    List<Notification> entities,
  ) {
    return entities.map((Notification e) => e.toDomain()).toList();
  }
}

extension NotificationTypeSettingsToCompanion on NotificationTypeSetting {
  NotificationsCompanion toCompanion() {
    return NotificationsCompanion.insert(
      notificationType: type.name,
      enabled: Value<bool>(enabled),
      frequency: frequency.name,
      preferredTimeHour: Value(preferredTime?.hour),
      preferredTimeMinute: Value(preferredTime?.minute),
    );
  }

  NotificationsCompanion toUpdateCompanion(int id) {
    return NotificationsCompanion(
      notificationType: Value(type.name),
      enabled: Value(enabled),
      frequency: Value(frequency.name),
      preferredTimeHour: Value(preferredTime?.hour),
      preferredTimeMinute: Value(preferredTime?.minute),
    );
  }
}
