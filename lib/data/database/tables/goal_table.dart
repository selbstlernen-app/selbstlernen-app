import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

class Goals extends Table with AutoIncrementingPrimaryKey {
  IntColumn get sessionId => integer().references(Sessions, #id)();

  TextColumn get title => text()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
