import 'package:freezed_annotation/freezed_annotation.dart';

part 'instance_strategy_with_details.freezed.dart';

@freezed
abstract class InstanceStrategyWithDetails with _$InstanceStrategyWithDetails {
  const factory InstanceStrategyWithDetails({
    required int id,
    required int instanceId,

    required int strategyId,
    required String strategyTitle,
    String? strategyExplanation,

    int? effectivenessRating,
    String? userReflection,
  }) = _InstanceStrategyWithDetails;
}
