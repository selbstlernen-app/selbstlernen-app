import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';

extension LearningStrategyToModel on LearningStrategy {
  LearningStrategyModel toDomain() {
    return LearningStrategyModel(
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
