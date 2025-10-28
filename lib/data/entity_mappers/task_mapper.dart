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
