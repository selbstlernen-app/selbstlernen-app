import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/goal_model.dart';

extension GoalToModelMapper on Goal {
  GoalModel toDomain() {
    return GoalModel(
      id: id.toString(),
      title: title,
      sessionId: sessionId.toString(),
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  static List<GoalModel> mapFromListOfEntity(List<Goal> entities) {
    return entities.map((Goal e) => e.toDomain()).toList();
  }
}

extension GoalToCompanionMapper on GoalModel {
  GoalsCompanion toCompanion() {
    return GoalsCompanion(
      title: Value<String>(title),
      sessionId: sessionId != null
          ? Value<int>(int.parse(sessionId!))
          : const Value<int>.absent(),
      isCompleted: Value<bool>(isCompleted),
      completedAt: completedAt != null
          ? Value<DateTime>(completedAt!)
          : const Value<DateTime>.absent(),
      createdAt: Value<DateTime>(createdAt ?? DateTime.now()),
    );
  }
}
