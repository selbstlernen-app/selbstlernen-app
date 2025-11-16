import 'package:srl_app/domain/models/goal_model.dart';

abstract class GoalRepository {
  // CRUD operations
  Future<List<GoalModel>> getGoalsBySessionId(int sessionId);
  Stream<List<GoalModel>> watchGoalsBySessionId(int sessionId);
  Future<int> addGoal(GoalModel goal);
  Future<void> deleteGoal(int goalId);
  Future<int> updateGoal(int goalId, GoalModel updatedGoal);
  Future<void> deleteGoalsBySessionId(int sessionId);
}
