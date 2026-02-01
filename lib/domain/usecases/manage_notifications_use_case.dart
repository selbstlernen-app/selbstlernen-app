import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/notification_repository.dart';

class ManageNotificationsUseCase {
  const ManageNotificationsUseCase(
    this.notificationRepository, {
    required this.notificationService,
  });

  final NotificationRepository notificationRepository;
  final NotificationService notificationService;

  Stream<List<NotificationTypeSetting>> watchPreferences() {
    return notificationRepository.watchPreferences();
  }

  Future<void> updatePreference(
    NotificationType type,
    NotificationTypeSetting setting,
  ) async {
    final service = NotificationService();

    if (!setting.enabled) {
      await service.cancelNotificationsForType(setting.type);
    } else {
      await service.scheduleNotification(
        type: setting.type,
        frequency: setting.frequency,
        preferredTime: setting.preferredTime,
        customMessage: setting.customMessage,
      );
    }

    return notificationRepository.updateTypeSettings(type, setting);
  }

  Future<void> toggleNotificationType({
    required NotificationType type,
    required bool isEnabled,
    required NotificationTypeSetting setting,
  }) async {
    await _syncSystemNotification(setting);

    return notificationRepository.toggleNotificationType(
      type,
      enabled: isEnabled,
    );
  }

  Future<void> _syncSystemNotification(NotificationTypeSetting setting) async {
    final service = NotificationService();
    if (!setting.enabled) {
      await service.cancelNotificationsForType(setting.type);
    } else {
      await service.scheduleNotification(
        type: setting.type,
        frequency: setting.frequency,
        preferredTime: setting.preferredTime,
        customMessage: setting.customMessage,
      );
    }
  }
}
