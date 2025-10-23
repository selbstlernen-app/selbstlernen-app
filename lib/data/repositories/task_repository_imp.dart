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
  Future deleteTask(int taskId) {
    return taskDao.deleteTask(taskId);
  }

  @override
  Stream<List<TaskModel>> getAllTasksFor(int sessionId) {
    return taskDao
        .watchAllTasksFor(sessionId)
        .map((taskList) => TaskToModelMapper.mapFromListOfEntity(taskList));
  }

  @override
  Future<int> updateTask(int taskId, TaskModel updatedtask) {
    return taskDao.updateTask(taskId, updatedtask.toCompanion());
  }
}
