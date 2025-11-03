import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_instance_model.freezed.dart';

@freezed
abstract class SessionInstanceModel with _$SessionInstanceModel {
  const SessionInstanceModel._();

  const factory SessionInstanceModel({
    String? id,
    required String sessionId,
    DateTime? scheduledDate,
    @Default(SessionStatus.scheduled) SessionStatus status,
    // TODO: add interesting measures here
    @Default(0) int totalCompletedGoals,
    @Default(0) int totalCompletedTasks,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _SessionInstanceModel;
}

enum SessionStatus { scheduled, completed, paused, cancelled }
