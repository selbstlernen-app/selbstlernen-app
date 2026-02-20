import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/learning_strategy/strategy_usage_for_session.dart';

part 'session_statistics.freezed.dart';

@freezed
abstract class SessionStatistics with _$SessionStatistics {
  const factory SessionStatistics({
    required int totalInstances,
    required int completedInstances,
    required int skippedInstances,
    required int missedInstances,

    // Time Measurements
    required int totalFocusMinutes,
    required int totalBreakMinutes,

    // Goal/Task Productivity
    /// All goals ever completed, across session instances
    required int totalGoalsCompleted,

    /// All tasks ever completed, across session instances
    required int totalTasksCompleted,

    /// Learning Strategies most commonly used in the session
    required List<StrategyUsageForSession> strategyUsage,

    double? averageMood,
    DateTime? lastSessionDate,
    DateTime? firstSessionDate,
  }) = _SessionStatistics;
  const SessionStatistics._();

  double get averageFocusMinutesPerSession =>
      completedInstances > 0 ? totalFocusMinutes / completedInstances : 0.0;

  double get averageBreakMinutesPerSession =>
      completedInstances > 0 ? totalBreakMinutes / completedInstances : 0.0;

  double get averageGoalsPerSession =>
      completedInstances > 0 ? totalGoalsCompleted / completedInstances : 0.0;

  double get averageTasksPerSession =>
      completedInstances > 0 ? totalTasksCompleted / completedInstances : 0.0;
}
