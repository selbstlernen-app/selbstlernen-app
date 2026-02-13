import 'package:freezed_annotation/freezed_annotation.dart';

part 'strategy_usage_for_session.freezed.dart';

/// Model to get aggregated statistics of a strategy
/// for a session (across instances)
@freezed
abstract class StrategyUsageForSession with _$StrategyUsageForSession {
  const factory StrategyUsageForSession({
    required int strategyId,
    required String strategyTitle,
    required int timesUsed,
    required List<int> ratings,
    String? strategyExplanation,
  }) = _StrategyUsageForSession;

  const StrategyUsageForSession._();

  double? get averageRating {
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
