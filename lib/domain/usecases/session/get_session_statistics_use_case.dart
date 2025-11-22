import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

/// Use case when wanting to get statistics for a specific session;
/// Shown after a session has been conducted
class GetSessionStatisticsUseCase {
  const GetSessionStatisticsUseCase(
    this.instanceRepository,
    this.sessionRepository,
  );

  final SessionInstanceRepository instanceRepository;
  final SessionRepository sessionRepository;

  Future<SessionStatistics> call(int sessionId) async {
    final SessionModel session = await sessionRepository.getSessionById(
      sessionId,
    );

    final List<SessionInstanceModel> instances = await instanceRepository
        .getAllInstancesBySessionId(sessionId);

    if (instances.isEmpty) {
      return const SessionStatistics(
        totalInstances: 0,
        completedInstances: 0,
        skippedInstances: 0,
        inProgressInstances: 0,
        totalFocusMinutes: 0,
        totalBreakMinutes: 0,
        totalFocusPhases: 0,
        totalCompletedBlocks: 0,
        totalGoalsCompleted: 0,
        totalTasksCompleted: 0,
        currentStreak: 0,
        longestStreak: 0,
      );
    }

    return _calculateStats(instances, session);
  }

  SessionStatistics _calculateStats(
    List<SessionInstanceModel> instances,
    SessionModel session,
  ) {
    // Sort instances by date
    final List<SessionInstanceModel> sortedInstances =
        <SessionInstanceModel>[...instances]..sort(
          (SessionInstanceModel a, SessionInstanceModel b) =>
              a.scheduledAt.compareTo(b.scheduledAt),
        );

    // Calculate aggregates
    final List<SessionInstanceModel> completed = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.completed)
        .toList();
    final List<SessionInstanceModel> skipped = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.skipped)
        .toList();
    final List<SessionInstanceModel> inProgress = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.inProgress)
        .toList();

    final int totalFocusSeconds = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalFocusSecondsElapsed,
    );
    final int totalBreakSeconds = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalBreakSecondsElapsed,
    );
    final int totalGoals = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedGoals,
    );
    final int totalTasks = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedTasks,
    );
    final int totalPhases = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalFocusPhases,
    );
    final int totalBlocks = completed.fold<int>(
      0,
      (int sum, SessionInstanceModel i) => sum + i.totalCompletedBlocks,
    );

    // Calculate average mood
    final List<SessionInstanceModel> completedWithMood = completed
        .where((SessionInstanceModel i) => i.mood != null)
        .toList();
    final double? averageMood = completedWithMood.isNotEmpty
        ? completedWithMood.fold<int>(
                0,
                (int sum, SessionInstanceModel i) => sum + i.mood!,
              ) /
              completedWithMood.length
        : null;

    // Calculate streaks
    final ({int current, int longest}) streaks = _calculateStreaks(
      sortedInstances,
    );

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
      inProgressInstances: inProgress.length,
      totalFocusMinutes: totalFocusSeconds ~/ 60,
      totalBreakMinutes: totalBreakSeconds ~/ 60,
      totalFocusPhases: totalPhases,
      totalCompletedBlocks: totalBlocks,
      totalGoalsCompleted: totalGoals,
      totalTasksCompleted: totalTasks,
      currentStreak: streaks.current,
      longestStreak: streaks.longest,
      averageMood: averageMood,
      lastSessionDate: sortedInstances.last.scheduledAt,
      firstSessionDate: sortedInstances.first.scheduledAt,
    );
  }

  ({int current, int longest}) _calculateStreaks(
    List<SessionInstanceModel> sortedInstances,
  ) {
    if (sortedInstances.isEmpty) return (current: 0, longest: 0);

    final List<SessionInstanceModel> completed = sortedInstances
        .where((SessionInstanceModel i) => i.status == SessionStatus.completed)
        .toList();

    if (completed.isEmpty) return (current: 0, longest: 0);

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    DateTime? lastDate;

    for (final SessionInstanceModel instance in completed.reversed) {
      final DateTime date = instance.scheduledAt;

      if (lastDate == null) {
        // First iteration
        currentStreak = 1;
        tempStreak = 1;
      } else {
        final int daysDiff = lastDate.difference(date).inDays;

        if (daysDiff == 1) {
          // Consecutive day
          tempStreak++;
          if (instance == completed.first) {
            currentStreak = tempStreak;
          }
        } else {
          // Streak broken
          longestStreak = tempStreak > longestStreak
              ? tempStreak
              : longestStreak;
          tempStreak = 1;
          if (instance == completed.first) {
            currentStreak = 1;
          }
        }
      }

      lastDate = date;
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return (current: currentStreak, longest: longestStreak);
  }
}
