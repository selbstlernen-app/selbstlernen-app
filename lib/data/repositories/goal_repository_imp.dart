import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/goal_model.dart';

class GoalRepositoryImp implements GoalRepository {
  @override
  Future<int> addGoal(GoalModel goal) {
    // TODO: implement addGoal
    throw UnimplementedError();
  }

  @override
  Future deleteGoal(int goalId) {
    // TODO: implement deleteGoal
    throw UnimplementedError();
  }

  @override
  Stream<List<GoalModel>> getAllGoalsFor(int sessionId) {
    // TODO: implement getAllGoalsFor
    throw UnimplementedError();
  }

  @override
  Future<int> updateSession(int goalId, GoalModel updatedGoal) {
    // TODO: implement updateSession
    throw UnimplementedError();
  }
}
