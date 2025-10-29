import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/task_repository.dart';

class FullSessionUseCase {
  const FullSessionUseCase(
    this.repository,
    this.goalRepository,
    this.taskRepository,
  );

  final SessionRepository repository;
  final TaskRepository taskRepository;
  final GoalRepository goalRepository;

  Future<FullSessionModel> getFullModel(int sessionId) async {
    SessionModel session = await repository.getSessionById(sessionId);
    List<GoalModel> goals = await goalRepository.getAllGoalsFor(sessionId);
    List<TaskModel> tasks = await taskRepository.getAllTasksFor(sessionId);

    FullSessionModel fullSessionModel = FullSessionModel(
      session: session,
      goals: goals,
      tasks: tasks,
    );
    return fullSessionModel;
  }

  Future<void> deleteFullModel(int sessionId) async {
    await repository.deleteSession(sessionId);
    await goalRepository.deleteAllGoalsFor(sessionId);
    await taskRepository.deleteAllTasksFor(sessionId);
  }
}
