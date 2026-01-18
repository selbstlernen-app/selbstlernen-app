import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_strategy_model.freezed.dart';

@freezed
abstract class LearningStrategyModel with _$LearningStrategyModel {
  const factory LearningStrategyModel({
    String? id,

    required String title,
    String? explanation,
  }) = _LearningStrategyModel;
}
