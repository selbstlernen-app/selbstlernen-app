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
  Future<List<Task>> getTasksBySessionId(int sessionId) async {
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

  Stream<List<Task>> watchTasksBySessionId(int sessionId) {
    return (select(tasks)..where(
          ($TasksTable task) =>
              task.sessionId.equals(sessionId) &
              task.keptForFutureSessions.equals(true),
        ))
        .watch();
  }

  // Watch all tasks of a session that are active,
  //i.e. kept for future sessions and scheduled for a session specific date
  Stream<List<Task>> watchTasksBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    );
    return (select(tasks)..where(
          ($TasksTable task) =>
              task.sessionId.equals(sessionId) &
              (task.keptForFutureSessions.equals(true) |
                  task.createdAt.isBetweenValues(startOfDay, endOfDay)),
        ))
        .watch();
  }

  // Update task
  Future<int> updateTask(int id, TasksCompanion companion) async {
    return (update(
      tasks,
    )..where(($TasksTable tbl) => tbl.id.equals(id))).write(companion);
  }

  Future<int> updateTaskFutureStatus(int id, bool status) async {
    return (update(tasks)..where(($TasksTable tbl) => tbl.id.equals(id))).write(
      TasksCompanion(keptForFutureSessions: Value<bool>(status)),
    );
  }

  // Delete task
  Future<int> deleteTask(int id) async {
    return await (delete(
      tasks,
    )..where(($TasksTable s) => s.id.equals(id))).go();
  }

  // Delete all tasks of a session
  Future<int> deleteTasksBySessionId(int sessionId) async {
    return await (delete(
      tasks,
    )..where(($TasksTable s) => s.sessionId.equals(sessionId))).go();
  }
}
