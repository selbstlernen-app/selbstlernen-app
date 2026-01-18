import 'package:srl_app/data/database/daos/learning_strategy_dao.dart';
import 'package:srl_app/data/entity_mappers/strategy_mapper.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/strategy_repository.dart';

class StrategyRepositoryImp implements StrategyRepository {
  StrategyRepositoryImp(this.learningStrategyDao);

  final LearningStrategyDao learningStrategyDao;

  @override
  Future<List<LearningStrategyModel>> getLearningStrategies() async {
    final entities = await learningStrategyDao.getAllStrats();
    return LearningStrategyToModel.mapFromListOfEntity(entities);
  }

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
}
