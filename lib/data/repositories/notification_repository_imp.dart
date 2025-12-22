import 'package:flutter/material.dart';
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
    if (entities.isEmpty) {
      await initializePreferences();
    }
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
  Stream<List<NotificationTypeSetting>> watchPreferences() async* {
    final stream = notificationDao.watchAllSettings().map(
      NotificationToModelMapper.mapFromListOfEntity,
    );
    final firstList = await stream.first;

    if (firstList.isEmpty) {
      await initializePreferences();
    }

    yield* stream;
  }

  Future<void> initializePreferences() async {
    for (final type in NotificationType.values) {
      final notification = NotificationTypeSetting(
        type: type,
        frequency: NotificationFrequency.daily,
        enabled: false,
        preferredTime: const TimeOfDay(hour: 9, minute: 0),
      );
      await notificationDao.addSetting(notification.toCompanion());
    }
  }
}
