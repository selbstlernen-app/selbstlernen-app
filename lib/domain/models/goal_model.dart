import 'package:freezed_annotation/freezed_annotation.dart';

part "goal_model.freezed.dart";

@freezed
abstract class GoalModel with _$GoalModel {
  const GoalModel._();

  const factory GoalModel({
    String? id,
    required String title,
    String? sessionId,
    required bool isCompleted,
    required bool keptForFutureSessions,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _GoalModel;
}
