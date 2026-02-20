import 'package:drift/drift.dart';
import 'package:srl_app/data/database/tables/learning_strategy/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/session_instance_table.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

/// Table linking strategy to instance
class SessionInstanceStrategies extends Table with AutoIncrementingPrimaryKey {
  IntColumn get instanceId => integer().references(
    SessionInstances,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get strategyId => integer().references(
    LearningStrategies,
    #id,
    onDelete: KeyAction.cascade,
  )();

  // Ratings are stored per instance
  IntColumn get effectivenessRating => integer().nullable()();
  TextColumn get userReflection =>
      text().withLength(min: 0, max: 500).nullable()();
}
