import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/learning_strategy/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy/session_instance_strategy_table.dart';

part 'learning_strategy_dao.g.dart';

@DriftAccessor(tables: <Type>[LearningStrategies, SessionInstanceStrategies])
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

  Future<List<StrategyWithStatsEntity>> getAllStrategiesWithStats() async {
    final query = select(learningStrategies).join([
      leftOuterJoin(
        sessionInstanceStrategies,
        sessionInstanceStrategies.strategyId.equalsExp(learningStrategies.id),
      ),
    ])..groupBy([learningStrategies.id]);

    final results = await query.get();

    final strategyStats = <int, StrategyWithStatsEntity>{};

    // First pass: collect all strategies
    for (final row in results) {
      final strategy = row.readTable(learningStrategies);
      if (!strategyStats.containsKey(strategy.id)) {
        strategyStats[strategy.id] = StrategyWithStatsEntity(
          strategyId: strategy.id,
          title: strategy.title,
          explanation: strategy.explanation,
          timesUsed: 0,
          ratings: [],
        );
      }
    }

    // Second pass: get detailed usage for each strategy
    for (final strategyId in strategyStats.keys) {
      final usages = await (select(
        sessionInstanceStrategies,
      )..where((s) => s.strategyId.equals(strategyId))).get();

      strategyStats[strategyId]!.timesUsed = usages.length;
      strategyStats[strategyId]!.ratings = usages
          .where((u) => u.effectivenessRating != null)
          .map((u) => u.effectivenessRating!)
          .toList();
    }

    return strategyStats.values.toList()
      ..sort((a, b) => b.timesUsed.compareTo(a.timesUsed));
  }

  // Watch version
  Stream<List<StrategyWithStatsEntity>> watchAllStrategiesWithStats() {
    return select(learningStrategies).watch().asyncMap((_) {
      return getAllStrategiesWithStats();
    });
  }
}

class StrategyWithStatsEntity {
  StrategyWithStatsEntity({
    required this.strategyId,
    required this.title,
    required this.timesUsed,
    required this.ratings,
    this.explanation,
  });

  final int strategyId;
  final String title;
  final String? explanation;
  int timesUsed;
  List<int> ratings;
}
