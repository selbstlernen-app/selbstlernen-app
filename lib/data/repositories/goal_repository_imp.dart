import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/goal_dao.dart';
import 'package:srl_app/data/entity_mappers/goal_mapper.dart';
import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/goal_model.dart';

class GoalRepositoryImp implements GoalRepository {
  GoalRepositoryImp(this.goalDao);

  final GoalDao goalDao;

  @override
  Future<int> addGoal(GoalModel goal) {
    return goalDao.addGoal(goal.toCompanion());
  }

  @override
  Future<void> deleteGoal(int goalId) {
    return goalDao.deleteGoal(goalId);
  }

  @override
  Future<void> deleteGoalsBySessionId(int sessionId) {
    return goalDao.deleteGoalsBySessionId(sessionId);
  }

  @override
  Future<List<GoalModel>> getGoalsBySessionId(int sessionId) async {
    List<Goal> goalEntities = await goalDao.getGoalsBySessionId(sessionId);
    List<GoalModel> goals = GoalToModelMapper.mapFromListOfEntity(goalEntities);
    return goals;
  }

  @override
  Stream<List<GoalModel>> watchGoalsBySessionId(int sessionId) {
    return goalDao
        .watchGoalsBySessionId(sessionId)
        .map(
          (List<Goal> goalList) =>
              GoalToModelMapper.mapFromListOfEntity(goalList),
        );
  }

  @override
  Stream<List<GoalModel>> watchGoalsBySessionIdAndDate(
    int sessionId,
    DateTime sessionScheduledDate,
  ) {
    return goalDao
        .watchGoalsBySessionIdAndDate(sessionId, sessionScheduledDate)
        .map(
          (List<Goal> goalList) =>
              GoalToModelMapper.mapFromListOfEntity(goalList),
        );
  }

  @override
  Future<int> updateGoal(int goalId, GoalModel updatedGoal) {
    return goalDao.updateGoal(goalId, updatedGoal.toUpdateCompanion());
  }
}
