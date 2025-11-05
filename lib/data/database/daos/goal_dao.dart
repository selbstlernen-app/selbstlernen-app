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
  Future<List<Goal>> getAllGoalsFor(int sessionId) {
    return (select(
      goals,
    )..where(($GoalsTable goal) => goal.sessionId.equals(sessionId))).get();
  }

  // Watch all goals of a session
  Stream<List<Goal>> watchAllGoalsFor(int sessionId) {
    return (select(
      goals,
    )..where(($GoalsTable goal) => goal.sessionId.equals(sessionId))).watch();
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

  // Delete goal
  Future<int> deleteGoal(int id) async {
    return await (delete(
      goals,
    )..where(($GoalsTable s) => s.id.equals(id))).go();
  }

  // Delete all goals of a session
  Future<int> deleteAllGoalsFor(int sessionId) async {
    return await (delete(
      goals,
    )..where(($GoalsTable s) => s.sessionId.equals(sessionId))).go();
  }
}
