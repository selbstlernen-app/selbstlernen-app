import 'package:drift/drift.dart';

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  BoolColumn get isDarkMode => boolean().withDefault(const Constant(false))();

  IntColumn get primaryColor =>
      integer().withDefault(const Constant(4278238463))(); // sky in argb32

  // Id is always 0, cannot increase
  @override
  Set<Column> get primaryKey => {id};
}
