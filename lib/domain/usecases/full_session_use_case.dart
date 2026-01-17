import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/task_repository.dart';

class FullSessionUseCase {
  const FullSessionUseCase(
    this.repository,
    this.goalRepository,
    this.taskRepository,
    this.instanceRepository,
  );

  final SessionRepository repository;
  final TaskRepository taskRepository;
  final GoalRepository goalRepository;
  final SessionInstanceRepository instanceRepository;

  Future<FullSessionModel> getFullModel(int sessionId) async {
    final session = await repository.getSessionById(sessionId);
    final goals = await goalRepository.getGoalsBySessionId(sessionId);
    final tasks = await taskRepository.getTasksBySessionId(sessionId);

    final fullSessionModel = FullSessionModel(
      session: session,
      goals: goals,
      tasks: tasks,
    );
    return fullSessionModel;
  }

  Stream<FullSessionModel> watchFullSession(int sessionId) {
    final session$ = repository.watchSessionById(
      sessionId,
    );
    final goals$ = goalRepository.watchGoalsBySessionId(
      sessionId,
    );
    final tasks$ = taskRepository.watchTasksBySessionId(
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
  }
}
