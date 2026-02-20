import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/learning_strategy/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy/session_instance_strategy_table.dart';

import 'package:srl_app/data/database/tables/session_instance_table.dart';

part 'session_instance_strategy_dao.g.dart';

@DriftAccessor(
  tables: [SessionInstanceStrategies, LearningStrategies, SessionInstances],
)
class SessionInstanceStrategyDao extends DatabaseAccessor<AppDatabase>
    with _$SessionInstanceStrategyDaoMixin {
  SessionInstanceStrategyDao(super.attachedDatabase);

  // Add strategy to instance
  Future<void> addStrategyToInstance({
    required int instanceId,
    required int strategyId,
  }) {
    return into(sessionInstanceStrategies).insert(
      SessionInstanceStrategiesCompanion.insert(
        instanceId: instanceId,
        strategyId: strategyId,
      ),
    );
  }

  // Watch strategy links for an instance
  Stream<List<InstanceStrategyLink>> watchStrategyLinksForInstance(
    int instanceId,
  ) {
    final query = select(sessionInstanceStrategies).join([
      innerJoin(
        learningStrategies,
        learningStrategies.id.equalsExp(sessionInstanceStrategies.strategyId),
      ),
    ])..where(sessionInstanceStrategies.instanceId.equals(instanceId));

    return query.map((row) {
      return InstanceStrategyLink(
        instanceStrategy: row.readTable(sessionInstanceStrategies),
        learningStrategy: row.readTable(learningStrategies),
      );
    }).watch();
  }

  // Rate a strategy for an instance
  Future<bool> rateStrategy({
    required int instanceId,
    required int strategyId,
    required int effectivenessRating,
    String? userReflection,
  }) {
    return (update(sessionInstanceStrategies)..where(
          (s) =>
              s.instanceId.equals(instanceId) & s.strategyId.equals(strategyId),
        ))
        .write(
          SessionInstanceStrategiesCompanion(
            effectivenessRating: Value(effectivenessRating),
            userReflection: Value(userReflection),
          ),
        )
        .then((count) => count > 0);
  }

  // Get aggregated strategy usage for a session type
  Future<List<StrategyUsageForSessionEntity>> getStrategyUsageForSession(
    int sessionId,
  ) async {
    // Get all instances of this session
    final instances = await (select(
      sessionInstances,
    )..where((i) => i.sessionId.equals(sessionId))).get();

    if (instances.isEmpty) return [];

    // Join to get strategy details and ratings for
    // all instances of this session
    final query = select(sessionInstanceStrategies).join([
      innerJoin(
        learningStrategies,
        learningStrategies.id.equalsExp(sessionInstanceStrategies.strategyId),
      ),
      innerJoin(
        sessionInstances,
        sessionInstances.id.equalsExp(sessionInstanceStrategies.instanceId),
      ),
    ])..where(sessionInstances.sessionId.equals(sessionId));

    final results = await query.get();

    // Group by strategy ID
    final strategyMap = <int, StrategyUsageForSessionEntity>{};

    for (final row in results) {
      final instanceStrategy = row.readTable(sessionInstanceStrategies);
      final learningStrategy = row.readTable(learningStrategies);

      if (!strategyMap.containsKey(instanceStrategy.strategyId)) {
        strategyMap[instanceStrategy.strategyId] =
            StrategyUsageForSessionEntity(
              strategyId: instanceStrategy.strategyId,
              strategyTitle: learningStrategy.title,
              strategyExplanation: learningStrategy.explanation,
              timesUsed: 0,
              ratings: [],
            );
      }

      strategyMap[instanceStrategy.strategyId]!.timesUsed++;
      if (instanceStrategy.effectivenessRating != null) {
        strategyMap[instanceStrategy.strategyId]!.ratings.add(
          instanceStrategy.effectivenessRating!,
        );
      }
    }

    return strategyMap.values.toList()
      // Sort by usage
      ..sort((a, b) => b.timesUsed.compareTo(a.timesUsed));
  }

  // Watch aggregated strategy usage for a session type
  Stream<List<StrategyUsageForSessionEntity>> watchStrategyUsageForSession(
    int sessionId,
  ) {
    // Watch session instances changes, then recalculate stats
    return select(
      sessionInstances,
    ).watch().asyncMap((_) => getStrategyUsageForSession(sessionId));
  }
}

// Helper classes for DAO results
class InstanceStrategyLink {
  InstanceStrategyLink({
    required this.instanceStrategy,
    required this.learningStrategy,
  });
  final SessionInstanceStrategy instanceStrategy;
  final LearningStrategy learningStrategy;
}

class StrategyUsageForSessionEntity {
  StrategyUsageForSessionEntity({
    required this.strategyId,
    required this.strategyTitle,
    required this.timesUsed,
    required this.ratings,
    this.strategyExplanation,
  });
  final int strategyId;
  final String strategyTitle;
  final String? strategyExplanation;
  int timesUsed;
  List<int> ratings;
}
