import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/goal_table.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: <Type>[Goals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  // Insert goal
  Future<int> addGoal(GoalsCompanion goal) async {
    return await into(goals).insert(goal);
  }

  // Get all goals of a session
  Future<List<Goal>> getGoalsBySessionId(int sessionId) {
    return (select(
      goals,
    )..where(($GoalsTable goal) => goal.sessionId.equals(sessionId))).get();
  }

  /// Watch all goals of a session that are active,
  ///  i.e. such that are kept for future sessions or on the scheduled day of the session
  Stream<List<Goal>> watchGoalsBySessionId(int sessionId) {
    return (select(goals)..where(
          ($GoalsTable goal) =>
              goal.sessionId.equals(sessionId) &
              (goal.keptForFutureSessions.equals(true)),
        ))
        .watch();
  }

  Stream<List<Goal>> watchGoalsBySessionIdAndDate(
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

    return (select(goals)..where(
          ($GoalsTable goal) =>
              goal.sessionId.equals(sessionId) &
              (goal.keptForFutureSessions.equals(true) |
                  goal.createdAt.isBetweenValues(startOfDay, endOfDay)),
        ))
        .watch();
  }

  // Get goal by ID
  Stream<Goal?> getGoalById(int id) {
    return (select(
      goals,
    )..where(($GoalsTable s) => s.id.equals(id))).watchSingleOrNull();
  }

  // Update goal
  Future<int> updateGoal(int id, GoalsCompanion companion) async {
    return (update(
      goals,
    )..where(($GoalsTable tbl) => tbl.id.equals(id))).write(companion);
  }

  Future<int> updateGoalFutureStatus(int id, bool status) async {
    return (update(goals)..where(($GoalsTable tbl) => tbl.id.equals(id))).write(
      GoalsCompanion(keptForFutureSessions: Value<bool>(status)),
    );
  }

  // Delete goal
  Future<int> deleteGoal(int id) async {
    return await (delete(
      goals,
    )..where(($GoalsTable s) => s.id.equals(id))).go();
  }

  // Delete all goals of a session
  Future<int> deleteGoalsBySessionId(int sessionId) async {
    return await (delete(
      goals,
    )..where(($GoalsTable s) => s.sessionId.equals(sessionId))).go();
  }
}
