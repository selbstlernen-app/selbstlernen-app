import 'package:drift/drift.dart';

// TODO: rework later for notification settings etc.
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  // Id is always 0, cannot increase
  @override
  Set<Column> get primaryKey => {id};
}
