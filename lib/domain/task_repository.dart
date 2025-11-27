import 'package:srl_app/domain/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasksBySessionId(int sessionId);
  Stream<List<TaskModel>> watchTasksBySessionId(int sessionId);
  Stream<List<TaskModel>> watchTasksBySessionIdAndDate(
    int sessionId,
    DateTime sessionScheduledDate,
  );
  Future<int> addTask(TaskModel task);
  Future<void> deleteTask(int taskId);
  Future<int> updateTask(int taskId, TaskModel updatedTask);
  Future<int> updateTaskFutureStatus(int goalId, bool status);
  Future<void> deleteTasksBySessionId(int sessionId);
}
