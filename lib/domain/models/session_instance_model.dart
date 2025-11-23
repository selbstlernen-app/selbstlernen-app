import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_instance_model.freezed.dart';

@freezed
abstract class SessionInstanceModel with _$SessionInstanceModel {
  const SessionInstanceModel._();

  const factory SessionInstanceModel({
    String? id,
    required String sessionId,

    @Default(SessionStatus.scheduled) SessionStatus status,
    required DateTime scheduledAt,

    // Time Measures
    @Default(0) int totalFocusPhases,
    @Default(0) int totalCompletedBlocks,
    @Default(0) int totalFocusSecondsElapsed,

    /// small and long break both count towards break seconds elapsed
    @Default(0) int totalBreakSecondsElapsed,

    // Checked off goals/tasks
    @Default(0) int totalCompletedGoals,
    @Default(0) int totalCompletedTasks,

    // Reflection stats
    int? mood,
    String? notes,

    DateTime? completedAt,
    DateTime? createdAt,
  }) = _SessionInstanceModel;
}

enum SessionStatus {
  /// Session instance created but not started yet; on creation always in this state
  scheduled,

  /// User is currently doing the session
  inProgress,

  /// Finished session successfully
  completed,

  /// User explicitly skipped it; or past date and was never completed
  skipped,
}
