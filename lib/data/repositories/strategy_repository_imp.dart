import 'package:srl_app/data/database/daos/learning_strategy_dao.dart';
import 'package:srl_app/data/entity_mappers/strategy_mapper.dart';
import 'package:srl_app/domain/models/learning_strategy/learning_strategy_with_stats.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/repositories/strategy_repository.dart';

class StrategyRepositoryImp implements StrategyRepository {
  StrategyRepositoryImp(this.learningStrategyDao);

  final LearningStrategyDao learningStrategyDao;

  @override
  Future<void> updateLearningStrategy(
    LearningStrategyModel model,
    int id,
  ) async {
    final companion = model.toUpdateCompanion(0);

    await learningStrategyDao.updateStrat(companion, id);
  }

  @override
  Stream<List<LearningStrategyModel>> watchLearningStrategies() {
    return learningStrategyDao.watchAllStrats().map(
      LearningStrategyToModel.mapFromListOfEntity,
    );
  }

  @override
  Future<int> addLearningStrategy(LearningStrategyModel model) {
    return learningStrategyDao.addStrategy(model.toCompanion());
  }

  @override
  Future<int> deleteLearningStrategy(int id) {
    return learningStrategyDao.deleteLearningStrategy(id);
  }

  @override
  Future<List<LearningStrategyWithStats>> getAllStrategiesWithStats() async {
    final entities = await learningStrategyDao.getAllStrategiesWithStats();
    return entities.map(_entityToDomain).toList();
  }

  @override
  Stream<List<LearningStrategyWithStats>> watchAllStrategiesWithStats() {
    return learningStrategyDao.watchAllStrategiesWithStats().map((entities) {
      return entities.map(_entityToDomain).toList();
    });
  }

  @override
  Future<List<LearningStrategyWithStats>> getTopStrategies({
    int limit = 5,
  }) async {
    final all = await getAllStrategiesWithStats();
    return all.take(limit).toList();
  }

  @override
  Stream<List<LearningStrategyWithStats>> watchTopStrategies({int limit = 5}) {
    return watchAllStrategiesWithStats().map((all) => all.take(limit).toList());
  }

  LearningStrategyWithStats _entityToDomain(StrategyWithStatsEntity entity) {
    return LearningStrategyWithStats(
      strategyId: entity.strategyId,
      title: entity.title,
      explanation: entity.explanation,
      timesUsed: entity.timesUsed,
      ratings: entity.ratings,
    );
  }
}
