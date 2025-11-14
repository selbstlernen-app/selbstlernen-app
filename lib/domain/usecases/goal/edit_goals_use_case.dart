import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/goal_model.dart';

class EditGoalsUseCase {
  const EditGoalsUseCase(this.repository);
  final GoalRepository repository;

  Future<void> deleteGoal(int goalId) => repository.deleteGoal(goalId);

  Future<int> updateGoal(GoalModel goal) =>
      repository.updateGoal(int.parse(goal.id!), goal);
}
