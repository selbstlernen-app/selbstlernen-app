import 'package:srl_app/domain/models/goal_model.dart';

abstract class GoalRepository {
  Future<List<GoalModel>> getAllGoalsFor(int sessionId);
  Stream<List<GoalModel>> watchAllGoalsFor(int sessionId);
  Future<int> addGoal(GoalModel goal);
  Future<void> deleteGoal(int goalId);
  Future<int> updateGoal(int goalId, GoalModel updatedGoal);
  Future<void> deleteAllGoalsFor(int sessionId);
}
