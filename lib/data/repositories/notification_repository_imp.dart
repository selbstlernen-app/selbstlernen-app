import 'package:srl_app/data/database/daos/notification_dao.dart';
import 'package:srl_app/data/entity_mappers/notification_mapper.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/notification_repository.dart';

class NotificationRepositoryImp implements NotificationRepository {
  NotificationRepositoryImp(this.notificationDao);

  final NotificationDao notificationDao;

  @override
  Future<List<NotificationTypeSetting>> getPreferences() async {
    final entities = await notificationDao.getAllSettings();
    return NotificationToModelMapper.mapFromListOfEntity(entities);
  }

  @override
  Future<void> toggleNotificationType(
    NotificationType type, {
    required bool enabled,
  }) async {
    await notificationDao.updateEnabled(type, enabled: enabled);
  }

  @override
  Future<void> updateTypeSettings(
    NotificationType type,
    NotificationTypeSetting settings,
  ) async {
    final companion = settings.toUpdateCompanion(0);

    await notificationDao.updateSettings(
      companion,
      type,
    );
  }

  @override
  Stream<List<NotificationTypeSetting>> watchPreferences() {
    return notificationDao.watchAllSettings().map(
      NotificationToModelMapper.mapFromListOfEntity,
    );
  }
}
