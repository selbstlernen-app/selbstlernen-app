import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Sessions], daos: [SessionDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(path.join(dbFolder.path, "db.sqlite"));
    return NativeDatabase(file);
  });
}
