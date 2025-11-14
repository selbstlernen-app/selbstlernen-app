import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/goal_model.dart';

class CreateGoalsUseCase {
  const CreateGoalsUseCase(this.repository);
  final GoalRepository repository;

  Future<int> call(GoalModel goal) => repository.addGoal(goal);
}
