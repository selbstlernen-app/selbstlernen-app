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
  Future<void> deleteAllTasksFor(int sessionId) {
    return taskDao.deleteAllTasksFor(sessionId);
  }

  @override
  Future<List<TaskModel>> getAllTasksFor(int sessionId) async {
    List<Task> taskEntities = await taskDao.getAllTasksFor(sessionId);
    List<TaskModel> tasks = TaskToModelMapper.mapFromListOfEntity(taskEntities);
    return tasks;
  }

  @override
  Future<int> updateTask(int taskId, TaskModel updatedtask) {
    return taskDao.updateTask(taskId, updatedtask.toCompanion());
  }
}
