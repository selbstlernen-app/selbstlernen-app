import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_statistics.freezed.dart';

@freezed
abstract class SessionStatistics with _$SessionStatistics {
  const SessionStatistics._();

  const factory SessionStatistics({
    required int totalInstances,
    required int completedInstances,
    required int skippedInstances,
    required int inProgressInstances,
    // Time Measurements
    required int totalFocusMinutes,
    required int totalBreakMinutes,
    required int totalFocusPhases,
    required int totalCompletedBlocks,
    // Goal/Task Productivity
    required int totalGoalsCompleted,
    required int totalTasksCompleted,
    // TODO: rework streak logic//maybe instead of streak have sth like days learned in a row (depending on days)
    required int currentStreak,
    required int longestStreak,

    double? averageMood,
    DateTime? lastSessionDate,
    DateTime? firstSessionDate,
  }) = _SessionStatistics;

  /// How much progress has been done already; TODO: check for non-repeating sessions!
  double get completionRate =>
      totalInstances > 0 ? completedInstances / totalInstances : 0.0;

  double get skipRate =>
      totalInstances > 0 ? skippedInstances / totalInstances : 0.0;

  double get combinedRate => completionRate + skipRate;

  double get averageFocusMinutesPerSession =>
      completedInstances > 0 ? totalFocusMinutes / completedInstances : 0.0;

  double get averageBreakMinutesPerSession =>
      completedInstances > 0 ? totalBreakMinutes / completedInstances : 0.0;

  double get averageGoalsPerSession =>
      completedInstances > 0 ? totalGoalsCompleted / completedInstances : 0.0;

  double get averageTasksPerSession =>
      completedInstances > 0 ? totalTasksCompleted / completedInstances : 0.0;
}
