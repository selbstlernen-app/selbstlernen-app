import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/domain/task_repository.dart';

class TaskRepositoryImp implements TaskRepository {
  @override
  Future<int> addTask(TaskModel task) {
    // TODO: implement addTask
    throw UnimplementedError();
  }

  @override
  Future deleteTask(int taskId) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Stream<List<TaskModel>> getAllTasksFor(int sessionId) {
    // TODO: implement getAllTasksFor
    throw UnimplementedError();
  }

  @override
  Future<int> updateSession(int taskId, TaskModel updatedTask) {
    // TODO: implement updateSession
    throw UnimplementedError();
  }
}
