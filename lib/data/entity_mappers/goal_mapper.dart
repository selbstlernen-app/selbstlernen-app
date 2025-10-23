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
      title: Value(title),
      sessionId: sessionId != null
          ? Value(int.parse(sessionId!))
          : const Value.absent(),
      isCompleted: Value(isCompleted),
      completedAt: completedAt != null
          ? Value(completedAt!)
          : const Value.absent(),
      createdAt: Value(createdAt ?? DateTime.now()),
    );
  }
}
