import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/repositories/goal_repository.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';
import 'package:srl_app/domain/repositories/task_repository.dart';

/// Use case to calculate session statistics from all sessions
/// and their instances that exist and are active/archived in the database
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
        avgGoalsPerInstance: 0,
        avgTasksPerInstance: 0,
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

    final avgGoalsOfAverages =
        listOfStatistics.fold<double>(
          0,
          (sum, s) => sum + s.avgGoalsPerInstance,
        ) /
        listOfStatistics.length;

    final avgTasksOfAverages =
        listOfStatistics.fold<double>(
          0,
          (sum, s) => sum + s.avgTasksPerInstance,
        ) /
        listOfStatistics.length;

    return GeneralStatistics(
      totalInstances: totalInstances,
      totalFocusMinutes: totalFocusMinutes,
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
      avgGoalsPerInstance: avgGoalsOfAverages,
      avgTasksPerInstance: avgTasksOfAverages,
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

    final totalInstances = completed.length + skipped.length;

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

    final avgGoalsPerInstance = totalInstances == 0
        ? 0.0
        : totalGoals / totalInstances;
    final avgTasksPerInstance = totalInstances == 0
        ? 0.0
        : totalTasks / totalInstances;

    return GeneralStatistics(
      totalInstances: totalInstances,
      totalFocusMinutes: totalFocusSeconds ~/ 60,
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
      avgGoalsPerInstance: avgGoalsPerInstance,
      avgTasksPerInstance: avgTasksPerInstance,
    );
  }
}
