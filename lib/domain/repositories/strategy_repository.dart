import 'package:srl_app/domain/models/learning_strategy/learning_strategy_with_stats.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';

/// Abstract repository class for the learning strategy repository
abstract class StrategyRepository {
  Future<int> addLearningStrategy(LearningStrategyModel model);

  Stream<List<LearningStrategyModel>> watchLearningStrategies();

  Future<void> updateLearningStrategy(
    LearningStrategyModel model,
    int id,
  );

  Future<int> deleteLearningStrategy(int id);

  // Get usage stats (when selecting a strategy in the add session screen)
  Future<List<LearningStrategyWithStats>> getAllStrategiesWithStats();
  Stream<List<LearningStrategyWithStats>> watchAllStrategiesWithStats();
  Future<List<LearningStrategyWithStats>> getTopStrategies({int limit = 5});
  Stream<List<LearningStrategyWithStats>> watchTopStrategies({int limit = 5});
}
