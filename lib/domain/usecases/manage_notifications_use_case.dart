import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/notification_repository.dart';

class ManageNotificationsUseCase {
  const ManageNotificationsUseCase(this.notificationRepository);

  final NotificationRepository notificationRepository;

  Future<List<NotificationTypeSetting>> getPreferences() async {
    return notificationRepository.getPreferences();
  }

  Stream<List<NotificationTypeSetting>> watchPreferences() {
    return notificationRepository.watchPreferences();
  }

  Future<void> updatePreference(
    NotificationType type,
    NotificationTypeSetting settings,
  ) {
    return notificationRepository.updateTypeSettings(type, settings);
  }

  Future<void> toggleNotificationType({
    required NotificationType type,
    required bool isEnabled,
  }) {
    return notificationRepository.toggleNotificationType(
      type,
      enabled: isEnabled,
    );
  }
}
