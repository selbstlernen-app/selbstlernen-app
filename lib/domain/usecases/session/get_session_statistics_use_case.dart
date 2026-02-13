import 'package:rxdart/rxdart.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/learning_strategy/strategy_usage_for_session.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/repositories/goal_repository.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';
import 'package:srl_app/domain/repositories/task_repository.dart';

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

  Stream<SessionStatistics> watchStatistics(int sessionId) async* {
    // Watch all streams for session statistics to update on instance/session edits
    yield* Rx.combineLatest5(
      sessionRepository.watchSessionById(sessionId),
      instanceRepository.watchInstancesBySessionId(sessionId),
      goalRepository.watchGoalsBySessionId(sessionId),
      taskRepository.watchTasksBySessionId(sessionId),
      instanceRepository.watchStrategyUsageForSession(sessionId),
      (session, instances, goals, tasks, strategies) {
        if (instances.isEmpty) {
          return const SessionStatistics(
            totalInstances: 0,
            completedInstances: 0,
            skippedInstances: 0,
            missedInstances: 0,
            totalFocusMinutes: 0,
            totalBreakMinutes: 0,
            totalGoalsCompleted: 0,
            totalTasksCompleted: 0,
            strategyUsage: [],
          );
        }
        return _calculateStats(instances, session, goals, tasks, strategies);
      },
    );
  }

  SessionStatistics _calculateStats(
    List<SessionInstanceModel> instances,
    SessionModel session,
    List<GoalModel> goals,
    List<TaskModel> tasks,
    List<StrategyUsageForSession> strategies,
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
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
      averageMood: averageMood,
      lastSessionDate: sortedInstances.last.scheduledAt,
      firstSessionDate: sortedInstances.first.scheduledAt,
      strategyUsage: strategies,
    );
  }
}
