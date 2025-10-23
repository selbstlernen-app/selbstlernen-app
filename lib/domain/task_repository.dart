import 'package:srl_app/domain/models/task_model.dart';

abstract class TaskRepository {
  Stream<List<TaskModel>> getAllTasksFor(int sessionId);
  Future<int> addTask(TaskModel task);
  Future deleteTask(int taskId);
  Future<int> updateSession(int taskId, TaskModel updatedTask);
}
