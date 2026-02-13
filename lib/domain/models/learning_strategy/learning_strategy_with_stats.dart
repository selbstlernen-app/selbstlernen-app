import 'package:freezed_annotation/freezed_annotation.dart';
part 'learning_strategy_with_stats.freezed.dart';

@freezed
abstract class LearningStrategyWithStats with _$LearningStrategyWithStats {
  const factory LearningStrategyWithStats({
    required int strategyId,
    required String title,
    // Total times used across ALL sessions
    required int timesUsed,
    // All ratings across ALL instances
    required List<int> ratings,
    String? explanation,
  }) = _LearningStrategyWithStats;

  const LearningStrategyWithStats._();

  double? get averageRating {
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  bool get hasBeenUsed => timesUsed > 0;
}
