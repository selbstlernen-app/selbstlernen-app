import 'package:drift/drift.dart';

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
