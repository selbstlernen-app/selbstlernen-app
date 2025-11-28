import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String title,
    required bool isCompleted,
    required bool keptForFutureSessions,
    String? id,
    String? sessionId,
    String? goalId,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _TaskModel;
  const TaskModel._();
}
