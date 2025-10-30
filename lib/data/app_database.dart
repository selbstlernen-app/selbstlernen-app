import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:srl_app/data/database/daos/goal_dao.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/database/daos/task_dao.dart';
import 'package:srl_app/data/database/tables/session_table.dart';
import 'package:srl_app/data/database/tables/goal_table.dart';
import 'package:srl_app/data/database/tables/task_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[Sessions, Goals, Tasks],
  daos: <Type>[SessionDao, GoalDao, TaskDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(path.join(dbFolder.path, "db.sqlite"));

    // if (await file.exists()) {
    //   await file.delete();
    //   print("Drift database deleted!");
    // }

    return NativeDatabase(file);
  });
}
