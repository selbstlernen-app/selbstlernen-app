import 'package:freezed_annotation/freezed_annotation.dart';

part "task_model.freezed.dart";

@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    String? id,
    required String title,
    String? sessionId,
    String? goalId,
    required bool isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _TaskModel;
}
