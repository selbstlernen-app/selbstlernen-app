import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/task_model.dart';

extension TaskToModelMapper on Task {
  TaskModel toDomain() {
    return TaskModel(
      id: id.toString(),
      title: title,
      sessionId: sessionId.toString(),
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
    );
  }

  static List<TaskModel> mapFromListOfEntity(List<Task> entities) {
    return entities.map((Task e) => e.toDomain()).toList();
  }
}

extension TaskToCompanionMapper on TaskModel {
  TasksCompanion toCompanion() {
    return TasksCompanion(
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
