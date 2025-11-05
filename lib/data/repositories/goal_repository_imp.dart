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
  Future<void> deleteAllGoalsFor(int sessionId) {
    return goalDao.deleteAllGoalsFor(sessionId);
  }

  @override
  Future<List<GoalModel>> getAllGoalsFor(int sessionId) async {
    List<Goal> goalEntities = await goalDao.getAllGoalsFor(sessionId);
    List<GoalModel> goals = GoalToModelMapper.mapFromListOfEntity(goalEntities);
    return goals;
  }

  @override
  Stream<List<GoalModel>> watchAllGoalsFor(int sessionId) {
    return goalDao
        .watchAllGoalsFor(sessionId)
        .map(
          (List<Goal> goalList) =>
              GoalToModelMapper.mapFromListOfEntity(goalList),
        );
  }

  @override
  Future<int> updateGoal(int goalId, GoalModel updatedGoal) {
    return goalDao.updateGoal(goalId, updatedGoal.toCompanion());
  }
}
