import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/task_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: <Type>[Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // Insert task
  Future<int> addTask(TasksCompanion task) async {
    return await into(tasks).insert(task);
  }

  // Get all tasks of a session
  Future<List<Task>> getAllTasksFor(int sessionId) async {
    return (select(
      tasks,
    )..where(($TasksTable task) => task.sessionId.equals(sessionId))).get();
  }

  // Get task by ID
  Stream<Task?> getTaskById(int id) {
    return (select(
      tasks,
    )..where(($TasksTable s) => s.id.equals(id))).watchSingleOrNull();
  }

  // Update task
  Future<int> updateTask(int id, TasksCompanion companion) async {
    return (update(
      tasks,
    )..where(($TasksTable tbl) => tbl.id.equals(id))).write(companion);
  }

  // Delete task
  Future<int> deleteTask(int id) async {
    return await (delete(
      tasks,
    )..where(($TasksTable s) => s.id.equals(id))).go();
  }

  // Delete all tasks of a session
  Future<int> deleteAllTasksFor(int sessionId) async {
    return await (delete(
      tasks,
    )..where(($TasksTable s) => s.sessionId.equals(sessionId))).go();
  }
}
