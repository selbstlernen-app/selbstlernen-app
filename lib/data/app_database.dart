import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:srl_app/data/database/daos/goal_dao.dart';
import 'package:srl_app/data/database/daos/learning_strategy_dao.dart';
import 'package:srl_app/data/database/daos/notification_dao.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/database/daos/session_instance_dao.dart';
import 'package:srl_app/data/database/daos/session_instance_strategy_dao.dart';
import 'package:srl_app/data/database/daos/settings_dao.dart';
import 'package:srl_app/data/database/daos/task_dao.dart';
import 'package:srl_app/data/database/tables/goal_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy/session_instance_strategy_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy/session_strategy_table.dart';
import 'package:srl_app/data/database/tables/notifications_table.dart';
import 'package:srl_app/data/database/tables/session_instance_table.dart';
import 'package:srl_app/data/database/tables/session_table.dart';
import 'package:srl_app/data/database/tables/settings_table.dart';
import 'package:srl_app/data/database/tables/task_table.dart';
import 'package:srl_app/data/entity_mappers/session_mapper.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

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
    SessionStrategies,
    SessionInstanceStrategies,
  ],
  daos: <Type>[
    SessionDao,
    GoalDao,
    TaskDao,
    SessionInstanceDao,
    SettingsDao,
    NotificationDao,
    LearningStrategyDao,
    SessionInstanceStrategyDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await _insertDefaultStrategies();
      },

      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(learningStrategies);
          await _insertDefaultStrategies();
        }
        if (from == 2 && to == 3) {
          debugPrint(
            'Migrating database from v2 to v3 - will recreate all tables',
          );

          // Drop all existing tables
          await _dropAllTables(m);

          // Recreate with new schema
          await m.createAll();

          // Insert default data
          await _insertDefaultStrategies();

          debugPrint('Migration to v3 complete');
        }
      },
      beforeOpen: (details) async {
        // Enable cascade delete behavior in SQLite
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _dropAllTables(Migrator m) async {
    try {
      await m.drop(notifications);
    } on Exception catch (e) {
      debugPrint('Could not drop notifications: $e');
    }

    try {
      await m.drop(sessions);
    } on Exception catch (e) {
      debugPrint('Could not drop sessions: $e');
    }

    try {
      await m.drop(sessionInstances);
    } on Exception catch (e) {
      debugPrint('Could not drop sessionInstances: $e');
    }

    try {
      await m.drop(goals);
    } on Exception catch (e) {
      debugPrint('Could not drop goals: $e');
    }

    try {
      await m.drop(settings);
    } on Exception catch (e) {
      debugPrint('Could not drop goals: $e');
    }

    try {
      await m.drop(tasks);
    } on Exception catch (e) {
      debugPrint('Could not drop tasks: $e');
    }

    try {
      await m.drop(learningStrategies);
    } on Exception catch (e) {
      debugPrint('Could not drop learningStrategies: $e');
    }
  }

  Future<void> _insertDefaultStrategies() async {
    final defaults = [
      LearningStrategiesCompanion.insert(
        title: 'Mind-map erstellen',
        explanation: const Value<String>(
          'Das Thema wird visuell strukturiert, Hauptideen werden mit Unterpunkten verbunden, damit Zusammenhänge leichter erkannt und erinnert werden.',
        ),
      ),
      LearningStrategiesCompanion.insert(
        title: 'Notizen machen',
        explanation: const Value<String>(
          'Wichtige Inhalte werden in eigenen Worten festgehalten. Das aktive Formulieren hilft, Informationen besser zu verstehen und zu verankern.',
        ),
      ),
      LearningStrategiesCompanion.insert(
        title: 'Mit Freunden besprechen',
        explanation: const Value<String>(
          'Durch das Erklären und Diskutieren mit anderen werden Wissenslücken sichtbar und Inhalte aus verschiedenen Perspektiven vertieft.',
        ),
      ),
      LearningStrategiesCompanion.insert(
        title: 'Karteikarten erstellen',
        explanation: const Value<String>(
          'Kernbegriffe und Fragen werden auf Karten gesammelt, um Wissen gezielt und in kleinen Einheiten trainieren zu können.',
        ),
      ),
      LearningStrategiesCompanion.insert(
        title: 'Wiederholen',
        explanation: const Value<String>(
          'Regelmäßiges Auffrischen des Gelernten festigt das Wissen langfristig und verbessert die Abrufbarkeit in Prüfungen.',
        ),
      ),
    ];

    for (final strat in defaults) {
      await into(learningStrategies).insert(strat);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));

    // if (await file.exists()) {
    //   await file.delete();
    //   print('Drift database deleted!');
    // }

    return NativeDatabase(file);
  });
}
