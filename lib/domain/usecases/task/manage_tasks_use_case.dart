import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/repositories/task_repository.dart';

/// Use case handling all CRUD operations for task repository
class ManageTasksUseCase {
  const ManageTasksUseCase(this.repository);

  final TaskRepository repository;

  // Create
  Future<int> createTask(TaskModel task) => repository.addTask(task);

  // Read
  Stream<List<TaskModel>> watchTasksBySessionId(int sessionId) =>
      repository.watchTasksBySessionId(sessionId);

  Stream<List<TaskModel>> watchTasksBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) => repository.watchTasksBySessionIdAndDate(sessionId, date);

  // Update
  Future<int> updateTask(TaskModel task) =>
      repository.updateTask(int.parse(task.id!), task);

  Future<int> updateTaskFutureStatus(
    String taskId, {
    required bool keptForFutureSessions,
  }) => repository.updateTaskFutureStatus(
    int.parse(taskId),
    keptForFutureSessions: keptForFutureSessions,
  );

  // Delete
  Future<void> deleteTask(int taskId) => repository.deleteTask(taskId);
}
