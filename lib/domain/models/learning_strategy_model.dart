import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_strategy_model.freezed.dart';

@freezed
abstract class LearningStrategyModel with _$LearningStrategyModel {
  const factory LearningStrategyModel({
    required String title, String? id,
    String? explanation,
  }) = _LearningStrategyModel;
}
