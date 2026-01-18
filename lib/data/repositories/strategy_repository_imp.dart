import 'package:srl_app/data/database/daos/learning_strategy_dao.dart';
import 'package:srl_app/data/entity_mappers/strategy_mapper.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/strategy_repository.dart';

class StrategyRepositoryImp implements StrategyRepository {
  StrategyRepositoryImp(this.learningStrategyDao);

  final LearningStrategyDao learningStrategyDao;

  @override
  Future<List<LearningStrategyModel>> getLearningStrategies() async {
    var entities = await learningStrategyDao.getAllStrats();
    if (entities.isEmpty) {
      await initializeStrats();
      entities = await learningStrategyDao.getAllStrats();
    }
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

  Future<void> initializeStrats() async {
    final list = [
      const LearningStrategyModel(
        title: 'Mind-map erstellen',
        explanation:
            'Das Thema wird visuell strukturiert, Hauptideen werden mit Unterpunkten verbunden, damit Zusammenhänge leichter erkannt und erinnert werden.',
      ),
      const LearningStrategyModel(
        title: 'Notizen machen',
        explanation:
            'Wichtige Inhalte werden in eigenen Worten festgehalten. Das aktive Formulieren hilft, Informationen besser zu verstehen und zu verankern.',
      ),
      const LearningStrategyModel(
        title: 'Mit Freunden besprechen',
        explanation:
            'Durch das Erklären und Diskutieren mit anderen werden Wissenslücken sichtbar und Inhalte aus verschiedenen Perspektiven vertieft.',
      ),
      const LearningStrategyModel(
        title: 'Karteikarten erstellen',
        explanation:
            'Kernbegriffe und Fragen werden auf Karten gesammelt, um Wissen gezielt und in kleinen Einheiten trainieren zu können.',
      ),
      const LearningStrategyModel(
        title: 'Wiederholen',
        explanation:
            'Regelmäßiges Auffrischen des Gelernten festigt das Wissen langfristig und verbessert die Abrufbarkeit in Prüfungen.',
      ),
    ];

    for (final strat in list) {
      await learningStrategyDao.addStrategy(strat.toCompanion());
    }
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
