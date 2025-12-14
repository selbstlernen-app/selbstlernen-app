import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

class Settings extends Table with AutoIncrementingPrimaryKey {
  TextColumn get key => text().withLength(min: 1, max: 50)();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();
}
