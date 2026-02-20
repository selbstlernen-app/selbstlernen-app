import 'package:srl_app/data/database/daos/task_dao.dart';
import 'package:srl_app/data/entity_mappers/task_mapper.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/domain/repositories/task_repository.dart';

class TaskRepositoryImp implements TaskRepository {
  TaskRepositoryImp(this.taskDao);

  final TaskDao taskDao;

  @override
  Future<int> addTask(TaskModel task) {
    return taskDao.addTask(task.toCompanion());
  }

  @override
  Future<void> deleteTask(int taskId) {
    return taskDao.deleteTask(taskId);
  }

  @override
  Future<List<TaskModel>> getTasksBySessionId(int sessionId) async {
    final taskEntities = await taskDao.getTasksBySessionId(sessionId);
    final tasks = TaskToModelMapper.mapFromListOfEntity(taskEntities);
    return tasks;
  }

  @override
  Stream<List<TaskModel>> watchTasksBySessionId(int sessionId) {
    return taskDao
        .watchTasksBySessionId(sessionId)
        .map(
          TaskToModelMapper.mapFromListOfEntity,
        );
  }

  @override
  Stream<List<TaskModel>> watchTasksBySessionIdAndDate(
    int sessionId,
    DateTime sessionScheduledDate,
  ) {
    return taskDao
        .watchTasksBySessionIdAndDate(sessionId, sessionScheduledDate)
        .map(
          TaskToModelMapper.mapFromListOfEntity,
        );
  }

  @override
  Future<int> updateTask(int taskId, TaskModel updatedtask) {
    return taskDao.updateTask(taskId, updatedtask.toUpdateCompanion());
  }

  @override
  Future<int> updateTaskFutureStatus(
    int goalId, {
    required bool keptForFutureSessions,
  }) {
    return taskDao.updateTaskFutureStatus(
      goalId,
      keptForFutureSessions: keptForFutureSessions,
    );
  }
}
