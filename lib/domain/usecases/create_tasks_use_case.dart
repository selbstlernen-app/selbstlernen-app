import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/domain/task_repository.dart';

class CreateTasksUseCase {
  CreateTasksUseCase(this.repository);
  final TaskRepository repository;

  Future<int> call(TaskModel task) => repository.addTask(task);
}
