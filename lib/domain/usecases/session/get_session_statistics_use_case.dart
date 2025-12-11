import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/task_repository.dart';

/// Use case when wanting to get statistics for a specific session;
/// Shown after a session has been conducted
class GetSessionStatisticsUseCase {
  const GetSessionStatisticsUseCase(
    this.instanceRepository,
    this.sessionRepository,
    this.goalRepository,
    this.taskRepository,
  );

  final SessionInstanceRepository instanceRepository;
  final SessionRepository sessionRepository;
  final GoalRepository goalRepository;
  final TaskRepository taskRepository;

  Future<SessionStatistics> call(int sessionId) async {
    final session = await sessionRepository.getSessionById(
      sessionId,
    );

    final instances = await instanceRepository.getAllInstancesBySessionId(
      sessionId,
    );

    final goals = await goalRepository.getGoalsBySessionId(
      sessionId,
    );
    final tasks = await taskRepository.getTasksBySessionId(
      sessionId,
    );

    if (instances.isEmpty) {
      return const SessionStatistics(
        totalInstances: 0,
        completedInstances: 0,
        skippedInstances: 0,
        missedInstances: 0,
        totalFocusMinutes: 0,
        totalBreakMinutes: 0,
        totalFocusPhases: 0,
        totalCompletedBlocks: 0,
        totalGoalsCompleted: 0,
        totalTasksCompleted: 0,
      );
    }

    return _calculateStats(instances, session, goals, tasks);
  }

  SessionStatistics _calculateStats(
    List<SessionInstanceModel> instances,
    SessionModel session,
    List<GoalModel> goals,
    List<TaskModel> tasks,
  ) {
    // Sort instances by date
    final sortedInstances = <SessionInstanceModel>[...instances]
      ..sort(
        (SessionInstanceModel a, SessionInstanceModel b) =>
            a.scheduledAt.compareTo(b.scheduledAt),
      );

    // Calculate aggregates
    final completed = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.completed)
        .toList();
    final skipped = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.skipped)
        .toList();

    // Get all instances that should have been from start to today
    final shouldHaveInstances = session.isRepeating
        ? DateTimeUtils.countDaysBetweenDates(
            session.startDate!,
            DateTime.now(),
            session.selectedDays,
          )
        : 0;

    final missedInstances = session.isRepeating
        ? shouldHaveInstances - completed.length - skipped.length
        : 0;

    final totalFocusSeconds = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalFocusSecondsElapsed,
    );
    final totalBreakSeconds = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalBreakSecondsElapsed,
    );
    final totalGoals = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedGoals,
    );
    final totalTasks = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedTasks,
    );
    final totalPhases = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalFocusPhases,
    );
    final totalBlocks = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedBlocks,
    );

    // Calculate average mood
    final completedWithMood = completed
        .where((SessionInstanceModel i) => i.mood != null)
        .toList();

    final averageMood = completedWithMood.isNotEmpty
        ? completedWithMood.fold<int>(
                0,
                (int sum, SessionInstanceModel i) => sum + i.mood!,
              ) /
              completedWithMood.length
        : null;

    int totalInstances;
    if (session.isRepeating) {
      totalInstances = DateTimeUtils.countDaysBetweenDates(
        session.startDate!,
        session.endDate!,
        session.selectedDays,
      );
    } else {
      totalInstances = 1;
    }

    return SessionStatistics(
      totalInstances: totalInstances,
      completedInstances: completed.length,
      skippedInstances: skipped.length,
      missedInstances: missedInstances,
      totalFocusMinutes: totalFocusSeconds ~/ 60,
      totalBreakMinutes: totalBreakSeconds ~/ 60,
      totalFocusPhases: totalPhases,
      totalCompletedBlocks: totalBlocks,
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
      averageMood: averageMood,
      lastSessionDate: sortedInstances.last.scheduledAt,
      firstSessionDate: sortedInstances.first.scheduledAt,
    );
  }
}
