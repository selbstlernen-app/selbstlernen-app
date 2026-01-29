import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/models.dart';

part 'add_session_state.freezed.dart';

@freezed
abstract class AddSessionState with _$AddSessionState {
  const factory AddSessionState({
    String? sessionId,
    @Default('') String title,
    @Default(false) bool isRepeating,

    @Default(TimeOfDay(hour: 10, minute: 0)) TimeOfDay plannedTime,
    @Default(false) bool enableNotifications,

    // In case of repeating sessions
    DateTime? startDate,
    DateTime? endDate,
    @Default(<int>[]) List<int> selectedDays,

    // Goals and tasks
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,
    // In edit mode we may delete some tasks/goals indefinitely
    @Default(<String>{}) Set<String> taskIdsToDelete,
    @Default(<String>{}) Set<String> goalIdsToDelete,

    // Strategies
    @Default(<String>[]) List<String> learningStrategies,
    List<LearningStrategyModel>? availableStrategies,

    // Time
    @Default(SessionComplexity.simple) SessionComplexity sessionComplexity,
    @Default(25) int focusTimeMin,
    @Default(5) int breakTimeMin,
    @Default(15) int longBreakTimeMin,
    @Default(4) int focusPhases,

    // Prompts
    @Default(false) bool hasFocusPrompt,
    @Default(15) int focusPromptInterval,
    // Show independent of user inactivity
    @Default(false) bool showFocusPromptAlways,

    //Validation fields
    @Default(null) String? titleError,
    String? dateError,
    String? selectedDaysError,
    String? goalsError,

    // Edit mode
    @Default(false) bool isEditMode,
    @Default(true) bool isLoading,
  }) = _AddSessionState;
  const AddSessionState._();

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();

  List<TaskModel> tasksForGoal(String goalId) =>
      tasks.where((TaskModel task) => task.goalId == goalId).toList();

  int get totalPages {
    return sessionComplexity == SessionComplexity.advanced ? 6 : 5;
  }

  // Can go to prompter page
  bool get isTimeValid {
    if (focusTimeMin > 0) return true;
    return false;
  }

  // Can go to second page
  bool get canGoToSecondStep {
    if (title.isEmpty || titleError != null) return false;

    return true;
  }

  // Can go to second page
  bool get canGoToThirdPage {
    if (isRepeating) {
      final hasValidDates =
          startDate != null && endDate != null && startDate!.isBefore(endDate!);

      print(hasValidDates);
      print(selectedDays.isNotEmpty);
      return selectedDays.isNotEmpty && hasValidDates;
    }

    return true;
  }
}

enum SessionComplexity {
  // Diary / No-time (TODO: yet to decide if this is a use case students are interested in)
  none,
  // Basic countdown; only configure focus time here
  simple,
  // Pomodoro / Intervals
  advanced,
}
