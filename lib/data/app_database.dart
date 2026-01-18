import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:srl_app/data/database/daos/goal_dao.dart';
import 'package:srl_app/data/database/daos/learning_strategy_dao.dart';
import 'package:srl_app/data/database/daos/notification_dao.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/database/daos/session_instance_dao.dart';
import 'package:srl_app/data/database/daos/settings_dao.dart';
import 'package:srl_app/data/database/daos/task_dao.dart';
import 'package:srl_app/data/database/tables/goal_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/notifications_table.dart';
import 'package:srl_app/data/database/tables/session_instance_table.dart';
import 'package:srl_app/data/database/tables/session_table.dart';
import 'package:srl_app/data/database/tables/settings_table.dart';
import 'package:srl_app/data/database/tables/task_table.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Sessions,
    Goals,
    Tasks,
    SessionInstances,
    Settings,
    Notifications,
    LearningStrategies,
  ],
  daos: <Type>[
    SessionDao,
    GoalDao,
    TaskDao,
    SessionInstanceDao,
    SettingsDao,
    NotificationDao,
    LearningStrategyDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(learningStrategies);
        }
      },
      beforeOpen: (details) async {
        // Enable cascade delete behavior in SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));

    if (await file.exists()) {
      await file.delete();
      print('Drift database deleted!');
    }

    return NativeDatabase(file);
  });
}
