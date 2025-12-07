import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/general_statistics.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/task_repository.dart';

class GetGeneralStatisticsUseCase {
  const GetGeneralStatisticsUseCase({
    required this.instanceRepository,
    required this.sessionRepository,
    required this.goalRepository,
    required this.taskRepository,
  });

  final SessionRepository sessionRepository;
  final SessionInstanceRepository instanceRepository;
  final GoalRepository goalRepository;
  final TaskRepository taskRepository;

  Future<GeneralStatistics> call() async {
    final sessions = await sessionRepository.getAllSessions();

    final listOfStatistics = <GeneralStatistics>[];

    if (sessions.isEmpty) {
      return const GeneralStatistics(
        totalInstances: 0,
        totalFocusMinutes: 0,
        totalGoalsCompleted: 0,
        totalTasksCompleted: 0,
      );
    }

    for (final session in sessions) {
      final sessionId = int.parse(session.id!);
      final instances = await instanceRepository.getAllInstancesBySessionId(
        sessionId,
      );
      final goals = await goalRepository.getGoalsBySessionId(
        sessionId,
      );
      final tasks = await taskRepository.getTasksBySessionId(
        sessionId,
      );

      if (instances.isNotEmpty) {
        listOfStatistics.add(_calculateStats(instances, session, goals, tasks));
      }
    }

    final totalInstances = listOfStatistics.fold<int>(
      0,
      (int sum, GeneralStatistics i) => sum + i.totalInstances,
    );

    final totalFocusMinutes = listOfStatistics.fold<int>(
      0,
      (int sum, GeneralStatistics i) => sum + i.totalFocusMinutes,
    );

    final totalGoals = listOfStatistics.fold<int>(
      0,
      (int sum, GeneralStatistics i) => sum + i.totalGoalsCompleted,
    );

    final totalTasks = listOfStatistics.fold<int>(
      0,
      (int sum, GeneralStatistics i) => sum + i.totalTasksCompleted,
    );

    return GeneralStatistics(
      totalInstances: totalInstances,
      totalFocusMinutes: totalFocusMinutes,
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
    );
  }

  GeneralStatistics _calculateStats(
    List<SessionInstanceModel> instances,
    SessionModel session,
    List<GoalModel> goals,
    List<TaskModel> tasks,
  ) {
    // Calculate aggregates
    final completed = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.completed)
        .toList();
    final skipped = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.skipped)
        .toList();

    final totalFocusSeconds = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalFocusSecondsElapsed,
    );

    final totalGoals = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedGoals,
    );
    final totalTasks = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedTasks,
    );

    return GeneralStatistics(
      totalInstances: completed.length + skipped.length,
      totalFocusMinutes: totalFocusSeconds ~/ 60,
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
    );
  }
}
