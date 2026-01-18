import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/learning_strategy_table.dart';

part 'strategy_dao.g.dart';

@DriftAccessor(tables: <Type>[LearningStrategies])
class LearningStrategyDao extends DatabaseAccessor<AppDatabase>
    with _$LearningStrategyDaoMixin {
  LearningStrategyDao(super.attachedDatabase);

  /// Add strategy
  Future<int> addStrategy(
    LearningStrategiesCompanion strat,
  ) {
    return into(learningStrategies).insert(strat);
  }

  /// Get all strategies
  Future<List<LearningStrategy>> getAllStrats() {
    return select(learningStrategies).get();
  }

  /// Watch all notification type settings
  Stream<List<LearningStrategy>> watchAllStrats() {
    return select(learningStrategies).watch();
  }

  /// Update full strat
  Future<void> updateStrat(
    LearningStrategiesCompanion companion,
    int learningId,
  ) {
    return (update(
      learningStrategies,
    )..where((tbl) => tbl.id.equals(learningId))).write(companion);
  }

  /// Delete strat
  Future<int> deleteLearningStrategy(int id) async {
    return (delete(
      learningStrategies,
    )..where((tbl) => tbl.id.equals(id))).go();
  }
}
