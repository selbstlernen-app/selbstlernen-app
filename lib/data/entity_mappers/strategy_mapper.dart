import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/session_instance_strategy_dao.dart';
import 'package:srl_app/domain/models/learning_strategy/instance_strategy_with_details.dart';
import 'package:srl_app/domain/models/learning_strategy/strategy_usage_for_session.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';

extension LearningStrategyToModel on LearningStrategy {
  LearningStrategyModel toDomain() {
    return LearningStrategyModel(
      id: id.toString(),
      title: title,
      explanation: explanation,
    );
  }

  static List<LearningStrategyModel> mapFromListOfEntity(
    List<LearningStrategy> entities,
  ) {
    return entities.map((LearningStrategy e) => e.toDomain()).toList();
  }
}

extension LearningStrategyToCompanion on LearningStrategyModel {
  LearningStrategiesCompanion toCompanion() {
    return LearningStrategiesCompanion.insert(
      title: title,
      explanation: Value<String?>(explanation),
    );
  }

  LearningStrategiesCompanion toUpdateCompanion(int id) {
    return LearningStrategiesCompanion(
      title: Value(title),
      explanation: Value<String?>(explanation),
    );
  }
}

// Extension for InstanceStrategyLink -> InstanceStrategyWithDetails
extension InstanceStrategyLinkMapper on InstanceStrategyLink {
  InstanceStrategyWithDetails toDomain() {
    return InstanceStrategyWithDetails(
      id: instanceStrategy.id,
      instanceId: instanceStrategy.instanceId,
      strategyId: instanceStrategy.strategyId,
      strategyTitle: learningStrategy.title,
      strategyExplanation: learningStrategy.explanation,
      effectivenessRating: instanceStrategy.effectivenessRating,
      userReflection: instanceStrategy.userReflection,
    );
  }
}

// Extension for StrategyUsageForSessionEntity -> StrategyUsageForSession
extension StrategyUsageForSessionEntityMapper on StrategyUsageForSessionEntity {
  StrategyUsageForSession toDomain() {
    return StrategyUsageForSession(
      strategyId: strategyId,
      strategyTitle: strategyTitle,
      strategyExplanation: strategyExplanation,
      timesUsed: timesUsed,
      ratings: ratings,
    );
  }
}

// Batch mapper for lists
extension InstanceStrategyLinkListMapper on List<InstanceStrategyLink> {
  List<InstanceStrategyWithDetails> toDomainList() {
    return map((link) => link.toDomain()).toList();
  }
}

extension StrategyUsageForSessionEntityListMapper
    on List<StrategyUsageForSessionEntity> {
  List<StrategyUsageForSession> toDomainList() {
    return map((entity) => entity.toDomain()).toList();
  }
}
