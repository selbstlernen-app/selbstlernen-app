import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_instance_model.freezed.dart';

@freezed
abstract class SessionInstanceModel with _$SessionInstanceModel {
  const SessionInstanceModel._();

  const factory SessionInstanceModel({
    String? id,
    required String sessionId,
    @Default(SessionStatus.scheduled) SessionStatus status,

    // Time Measures
    @Default(0) int totalFocusPhases,
    @Default(0) int totalCompletedBlocks,
    @Default(0) int totalFocusSecondsElapsed,
    @Default(0) int totalBreakSecondsElapsed,

    // Checked off goals/tasks
    @Default(0) int totalCompletedGoals,
    @Default(0) int totalCompletedTasks,
    DateTime? completedAt,
    DateTime? createdAt,
  }) = _SessionInstanceModel;
}

enum SessionStatus { scheduled, completed, paused, cancelled }
