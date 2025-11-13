import 'package:rxdart/rxdart.dart';
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
    List<GoalModel> goals = await goalRepository.getGoalsBySessionId(sessionId);
    List<TaskModel> tasks = await taskRepository.getTasksBySessionId(sessionId);

    FullSessionModel fullSessionModel = FullSessionModel(
      session: session,
      goals: goals,
      tasks: tasks,
    );
    return fullSessionModel;
  }

  Stream<FullSessionModel> watchFullSession(int sessionId) {
    final Stream<SessionModel> session$ = repository.watchSessionById(
      sessionId,
    );
    final Stream<List<GoalModel>> goals$ = goalRepository.watchGoalsBySessionId(
      sessionId,
    );
    final Stream<List<TaskModel>> tasks$ = taskRepository.watchTasksBySessionId(
      sessionId,
    );

    return Rx.combineLatest3<
      SessionModel,
      List<GoalModel>,
      List<TaskModel>,
      FullSessionModel
    >(
      session$,
      goals$,
      tasks$,
      (SessionModel session, List<GoalModel> goals, List<TaskModel> tasks) =>
          FullSessionModel(session: session, goals: goals, tasks: tasks),
    );
  }

  Future<void> deleteFullModel(int sessionId) async {
    await repository.deleteSession(sessionId);
    await goalRepository.deleteGoalsBySessionId(sessionId);
    await taskRepository.deleteTasksBySessionId(sessionId);
  }
}
