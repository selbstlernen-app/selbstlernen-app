import 'package:srl_app/domain/models/notification_type_setting.dart';

abstract class NotificationRepository {
  /// Watch preferences for reactive UI
  Stream<List<NotificationTypeSetting>> watchPreferences();

  /// Update a preference
  Future<void> updateTypeSettings(
    NotificationType type,
    NotificationTypeSetting settings,
  );

  /// Toggle some notification type
  Future<void> toggleNotificationType(
    NotificationType type, {
    required bool enabled,
  });
}
