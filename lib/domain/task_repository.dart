import 'package:srl_app/domain/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getAllTasksFor(int sessionId);
  Stream<List<TaskModel>> watchAllTasksFor(int sessionId);
  Future<int> addTask(TaskModel task);
  Future<void> deleteTask(int taskId);
  Future<int> updateTask(int taskId, TaskModel updatedTask);
  Future<void> deleteAllTasksFor(int sessionId);
}
