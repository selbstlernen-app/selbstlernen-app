import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class SessionInstances extends Table with AutoIncrementingPrimaryKey {
  IntColumn get sessionId => integer().references(Sessions, #id)();
  TextColumn get status => textEnum<SessionStatus>().withDefault(
    const Constant<String>('scheduled'),
  )();
  DateTimeColumn get scheduledAt => dateTime()();

  IntColumn get totalFocusPhases =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get totalCompletedBlocks =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get totalFocusSecondsElapsed =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get totalBreakSecondsElapsed =>
      integer().withDefault(const Constant<int>(0))();

  IntColumn get totalCompletedGoals =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get totalCompletedTasks =>
      integer().withDefault(const Constant<int>(0))();
  RealColumn get completedGoalsRate =>
      real().withDefault(const Constant<double>(0))();
  RealColumn get completedTasksRate =>
      real().withDefault(const Constant<double>(0))();

  IntColumn get currentPhaseIndex =>
      integer().withDefault(const Constant<int>(0))();
  IntColumn get remainingSeconds => integer().nullable()();

  TextColumn get focusChecksJson =>
      text().withDefault(const Constant<String>('[]'))();

  IntColumn get mood => integer().nullable()();
  TextColumn get notes => text().nullable()();

  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
