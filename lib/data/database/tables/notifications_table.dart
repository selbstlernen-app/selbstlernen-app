import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

class Notifications extends Table with AutoIncrementingPrimaryKey {
  /// The notifcation type; see the NotificationTypeEnum
  TextColumn get notificationType => text()();

  /// Flag to see if type is enabled or not
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Frequency enum in which it shall be displayed
  TextColumn get frequency => text()();

  /// In case of motivational reminder, custom message to be displayed
  TextColumn get customMessage => text().nullable()();

  /// Preferred time at which the notification should be displayed
  IntColumn get preferredTimeHour => integer().nullable()();
  IntColumn get preferredTimeMinute => integer().nullable()();
}
