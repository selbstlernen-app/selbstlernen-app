import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/models.dart';

/// Use case handling all CRUD operations for goal repository
class ManageGoalUseCase {
  const ManageGoalUseCase(this.repository);

  final GoalRepository repository;

  // Create
  Future<int> createGoal(GoalModel goal) => repository.addGoal(goal);

  // Read
  Stream<List<GoalModel>> watchGoalsBySessionId(int sessionId) =>
      repository.watchGoalsBySessionId(sessionId);

  Stream<List<GoalModel>> watchGoalsBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) => repository.watchGoalsBySessionIdAndDate(sessionId, date);

  // Update
  Future<int> updateGoal(GoalModel goal) =>
      repository.updateGoal(int.parse(goal.id!), goal);

  Future<int> updateGoalFutureStatus(String goalId, bool status) =>
      repository.updateGoalFutureStatus(int.parse(goalId), status);

  // Delete
  Future<void> deleteGoal(int goalId) => repository.deleteGoal(goalId);
}
