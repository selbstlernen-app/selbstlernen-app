import 'package:srl_app/domain/models/goal_model.dart';

abstract class GoalRepository {
  Stream<List<GoalModel>> getAllGoalsFor(int sessionId);
  Future<int> addGoal(GoalModel goal);
  Future deleteGoal(int goalId);
  Future<int> updateGoal(int goalId, GoalModel updatedGoal);
}
