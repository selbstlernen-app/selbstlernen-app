import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_model.freezed.dart';

@freezed
abstract class GoalModel with _$GoalModel {
  const factory GoalModel({
    required String title,
    required bool isCompleted,
    required bool keptForFutureSessions,
    String? id,
    String? sessionId,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _GoalModel;
  const GoalModel._();
}
