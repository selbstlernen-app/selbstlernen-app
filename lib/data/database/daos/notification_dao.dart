import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/notifications_table.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: <Type>[Notifications])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.attachedDatabase);

  /// Add notification type settings
  Future<int> addSetting(
    NotificationsCompanion notification,
  ) {
    return into(notifications).insert(notification);
  }

  /// Watch all notification type settings
  Stream<List<Notification>> watchAllSettings() {
    return select(notifications).watch();
  }

  /// Update enabled flag only
  Future<void> updateEnabled(NotificationType type, {required bool enabled}) {
    return (update(
      notifications,
    )..where((tbl) => tbl.notificationType.equals(type.name))).write(
      NotificationsCompanion(
        enabled: Value(enabled),
      ),
    );
  }

  /// Update full settings
  Future<void> updateSettings(
    NotificationsCompanion companion,
    NotificationType type,
  ) {
    return (update(
      notifications,
    )..where((tbl) => tbl.notificationType.equals(type.name))).write(companion);
  }
}
