import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

class Goals extends Table with AutoIncrementingPrimaryKey {
  IntColumn get sessionId => integer().references(
    Sessions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get title => text()();

  /// Attribute with which newly added goals can be tracked
  /// independent of session status (e.g. made before the session was completed;
  /// inProgress)
  BoolColumn get keptForFutureSessions =>
      boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
