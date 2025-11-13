import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_stats.freezed.dart';

@freezed
abstract class SessionStats with _$SessionStats {
  const factory SessionStats({
    required int totalInstances,
    required int completedInstances,
    required int skippedInstances,
    required int totalFocusMinutes,
    required int totalCompletedGoals,
    required int totalCompletedTasks,
    required double completionRate, // completedInstances / totalInstances
    DateTime? lastCompletedAt,
    DateTime? nextScheduledDate, // If repeating sessions
  }) = _SessionStats;
}
