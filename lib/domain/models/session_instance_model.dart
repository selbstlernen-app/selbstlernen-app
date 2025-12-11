import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/focus_check.dart';

part 'session_instance_model.freezed.dart';

@freezed
abstract class SessionInstanceModel with _$SessionInstanceModel {
  const factory SessionInstanceModel({
    required String sessionId,
    required DateTime scheduledAt,
    String? id,

    @Default(SessionStatus.scheduled) SessionStatus status,

    // Time Measures
    @Default(0) int totalFocusPhases,
    @Default(0) int totalCompletedBlocks,
    @Default(0) int totalFocusSecondsElapsed,

    /// Small and long break both count towards break seconds elapsed
    @Default(0) int totalBreakSecondsElapsed,

    // Measures needed when re-covering a session in progress
    @Default(0) int currentPhaseIndex,
    int? remainingSeconds,

    // Checked off goals/tasks
    @Default(0) int totalCompletedGoals,
    @Default(0) int totalCompletedTasks,
    // Rate as relative measure
    @Default(0) double completedGoalsRate,
    @Default(0) double completedTasksRate,

    // Focus measure
    @Default([]) List<FocusCheck> focusChecks,

    // Reflection stats
    int? mood,
    String? notes,

    DateTime? completedAt,
    DateTime? createdAt,
  }) = _SessionInstanceModel;
  const SessionInstanceModel._();
}

enum SessionStatus {
  /// Session instance created but not started yet; on creation always
  /// in this state
  scheduled,

  /// User is currently doing the session
  inProgress,

  /// Finished session successfully
  completed,

  /// User explicitly skipped it; or past date and was never completed
  skipped,

  // User missed a session
  missed,
}
