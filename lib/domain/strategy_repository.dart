import 'package:srl_app/domain/models/learning_strategy_model.dart';

/// Abstract repository class for the learning strategy repository
abstract class StrategyRepository {
  Future<int> addLearningStrategy(LearningStrategyModel model);

  Future<List<LearningStrategyModel>> getLearningStrategies();

  Stream<List<LearningStrategyModel>> watchLearningStrategies();

  Future<void> updateLearningStrategy(
    LearningStrategyModel model,
    int id,
  );

  Future<int> deleteLearningStrategy(int id);
}
