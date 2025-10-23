import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/goal_table.dart';

part 'goal_dao.g.dart';

@DriftAccessor(tables: [Goals])
class GoalDao extends DatabaseAccessor<AppDatabase> with _$GoalDaoMixin {
  GoalDao(super.db);

  // Insert goal
  Future<int> addGoal(GoalsCompanion goal) async {
    return await into(goals).insert(goal);
  }

  // Watch all goals of a session
  Stream<List<Goal>> watchAllGoalsFor(int sessionId) {
    return (select(
      goals,
    )..where((goal) => goal.sessionId.equals(sessionId))).watch();
  }

  // Get goal by ID
  Stream<Goal?> getGoalById(int id) {
    return (select(goals)..where((s) => s.id.equals(id))).watchSingleOrNull();
  }

  // Update goal
  Future<int> updateGoal(int id, GoalsCompanion companion) async {
    return (update(goals)..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  // Delete goal
  Future<int> deleteGoal(int id) async {
    return await (delete(goals)..where((s) => s.id.equals(id))).go();
  }
}
