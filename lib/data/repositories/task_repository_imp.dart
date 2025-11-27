import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/task_dao.dart';
import 'package:srl_app/data/entity_mappers/task_mapper.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/domain/task_repository.dart';

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
  Future<void> deleteTasksBySessionId(int sessionId) {
    return taskDao.deleteTasksBySessionId(sessionId);
  }

  @override
  Future<List<TaskModel>> getTasksBySessionId(int sessionId) async {
    List<Task> taskEntities = await taskDao.getTasksBySessionId(sessionId);
    List<TaskModel> tasks = TaskToModelMapper.mapFromListOfEntity(taskEntities);
    return tasks;
  }

  @override
  Stream<List<TaskModel>> watchTasksBySessionId(int sessionId) {
    return taskDao
        .watchTasksBySessionId(sessionId)
        .map(
          (List<Task> taskList) =>
              TaskToModelMapper.mapFromListOfEntity(taskList),
        );
  }

  @override
  Future<int> updateTask(int taskId, TaskModel updatedtask) {
    return taskDao.updateTask(taskId, updatedtask.toUpdateCompanion());
  }

  @override
  Future<int> updateTaskCompleted(int taskId, bool isCompleted) {
    return taskDao.updateTaskCompleted(taskId, isCompleted);
  }
}
