import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';

part 'active_session_state.freezed.dart';

enum SessionPhase { focus, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

@freezed
abstract class ActiveSessionState with _$ActiveSessionState {
  const ActiveSessionState._();

  const factory ActiveSessionState({
    required FullSessionModel fullSession,
    SessionInstanceModel? instance,
    String? instanceId,
    DateTime? scheduledAt,
    @Default(SessionPhase.focus) SessionPhase currentPhase,
    @Default(TimerStatus.initial) TimerStatus timerStatus,
    @Default(0) int remainingSeconds,
    @Default(0) int totalFocusSecondsElapsed,
    @Default(0) int totalBreakSecondsElapsed,
    @Default(0) int totalLongBreakSecondsElapsed,

    @Default(0) int totalFocusPhases,
    @Default(0) int completedBlocks,
    DateTime? sessionStartTime,

    @Default(<String>{}) Set<String> completedGoalIds,
    @Default(<String>{}) Set<String> completedTaskIds,

    // Only for screen
    @Default(false) bool countUpwards,
  }) = _ActiveSessionState;

  List<TaskModel> get ungroupedTasks =>
      fullSession.tasks.where((TaskModel task) => task.goalId == null).toList();

  List<TaskModel> tasksForGoal(String goalId) => fullSession.tasks
      .where((TaskModel task) => task.goalId == goalId)
      .toList();
}
