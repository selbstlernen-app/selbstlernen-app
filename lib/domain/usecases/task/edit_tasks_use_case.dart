import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/task_repository.dart';

class EditTasksUseCase {
  const EditTasksUseCase(this.repository);
  final TaskRepository repository;

  Future<void> deleteTask(int taskId) => repository.deleteTask(taskId);

  Future<int> updateTask(TaskModel task) =>
      repository.updateTask(int.parse(task.id!), task);
}
