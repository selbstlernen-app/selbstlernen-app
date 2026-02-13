import 'package:srl_app/domain/models/learning_strategy/instance_strategy_with_details.dart';
import 'package:srl_app/domain/models/learning_strategy/learning_strategy_with_stats.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';
import 'package:srl_app/domain/repositories/strategy_repository.dart';

class ManageLearningStrategyUseCase {
  const ManageLearningStrategyUseCase(
    this.repo,
    this.sessionRepository,
    this.instanceRepository,
  );

  final StrategyRepository repo;
  final SessionRepository sessionRepository;
  final SessionInstanceRepository instanceRepository;

  Future<void> updateLearningStrategy(
    LearningStrategyModel model,
    int id,
  ) {
    return repo.updateLearningStrategy(model, id);
  }

  Future<int> addLearningStrategy(
    LearningStrategyModel model,
  ) {
    return repo.addLearningStrategy(model);
  }

  Future<int> deleteLearningStrategy(
    int id,
  ) {
    return repo.deleteLearningStrategy(id);
  }

  // Strategy per instance related
  Stream<List<InstanceStrategyWithDetails>> watchStrategiesForInstance(
    int instanceId,
  ) {
    return instanceRepository.watchStrategiesForInstance(instanceId);
  }

  Future<bool> rateStrategy({
    required int instanceId,
    required int strategyId,
    required int effectivenessRating,
  }) {
    return instanceRepository.rateStrategy(
      instanceId: instanceId,
      strategyId: strategyId,
      effectivenessRating: effectivenessRating,
    );
  }

  /// Gets the usage per strategy for a cumulative session
  Stream<List<LearningStrategyModel>> watchLearningStrategiesForSession(
    int sessionId,
  ) {
    return sessionRepository.watchLearningStrategiesForSession(sessionId);
  }

  /// Gets all learning strategies with their stats
  Stream<List<LearningStrategyWithStats>> watchAllStrategiesWithStats() {
    return repo.watchAllStrategiesWithStats();
  }
}
