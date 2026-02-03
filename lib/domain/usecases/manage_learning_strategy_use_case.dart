import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/strategy_repository.dart';

class ManageLearningStrategyUseCase {
  const ManageLearningStrategyUseCase(this.repo);

  final StrategyRepository repo;

  Stream<List<LearningStrategyModel>> watchLearningStrategies() {
    return repo.watchLearningStrategies();
  }

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
}
