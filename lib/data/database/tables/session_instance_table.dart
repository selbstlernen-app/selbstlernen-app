import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class SessionInstances extends Table with AutoIncrementingPrimaryKey {
  IntColumn get sessionId => integer().references(Sessions, #id)();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  TextColumn get status => textEnum<SessionStatus>().withDefault(
    const Constant<String>('scheduled'),
  )();
  IntColumn get totalCompletedGoals =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get totalCompletedTasks =>
      integer().withDefault(const Constant<int>(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
