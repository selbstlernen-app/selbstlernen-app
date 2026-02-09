import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_validator.dart';

part 'add_session_state.freezed.dart';

@freezed
abstract class AddSessionState with _$AddSessionState {
  const factory AddSessionState({
    String? sessionId,
    @Default('') String title,
    @Default(false) bool isRepeating,

    @Default(SessionComplexity.simple) SessionComplexity sessionComplexity,
    TimeOfDay? plannedTime,
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
    @Default(25) int focusTimeMin,
    @Default(5) int breakTimeMin,
    @Default(4) int pomodoroPhases,

    // Prompts
    @Default(false) bool hasFocusPrompt,
    @Default(15) int focusPromptInterval,
    // Show independent of user inactivity
    @Default(false) bool showFocusPromptAlways,

    // Edit mode
    @Default(false) bool isEditMode,
    @Default(true) bool isLoading,
  }) = _AddSessionState;
  const AddSessionState._();

  // Factory to initialize the state from the given model in edit mode
  factory AddSessionState.fromModel({
    required FullSessionModel fullSession,
    List<LearningStrategyModel>? existingStrategies,
  }) {
    final session = fullSession.session;
    return AddSessionState(
      sessionId: session.id,
      isEditMode: session.id != null,
      title: session.title,
      isRepeating: session.isRepeating,
      startDate: session.startDate,
      endDate: session.endDate,
      selectedDays: session.selectedDays,
      goals: fullSession.goals,
      tasks: fullSession.tasks,
      learningStrategies: session.learningStrategies,
      availableStrategies: existingStrategies,
      sessionComplexity: session.complexity,
      focusTimeMin: session.focusTimeMin,
      breakTimeMin: session.breakTimeMin,
      pomodoroPhases: session.pomodoroPhases,
      hasFocusPrompt: session.hasFocusPrompt,
      focusPromptInterval: session.focusPromptInterval,
      showFocusPromptAlways: session.showFocusPromptAlways,
      enableNotifications: session.hasNotification,
      plannedTime: session.plannedTime,
      isLoading: false,
    );
  }

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();

  List<TaskModel> tasksForGoal(String goalId) =>
      tasks.where((TaskModel task) => task.goalId == goalId).toList();

  int get totalPages {
    if (isEditMode) {
      return 5;
    }
    return 6;
  }

  // Can go to prompter page
  bool get isTimeValid {
    if (focusTimeMin > 0) return true;
    return false;
  }

  // Can go to second page
  bool get canGoToSecondStep {
    if (title.trim().isEmpty || titleError != null) return false;
    return true;
  }

  String? get titleError {
    if (title.trim().isEmpty) return 'Titel kann nicht leer sein';
    if (title.trim().length < 3) {
      return 'Titel muss mind. 3 Charaktere lang sein';
    }
    return null;
  }

  String? get goalError {
    return (goals.isEmpty && tasks.isEmpty)
        ? 'Es muss mind. ein Ziel oder eine Aufgaben definiert worden sein.'
        : null;
  }

  String? get dateError {
    return AddSessionValidator.validateDate(
      startDate: startDate,
      endDate: endDate,
    );
  }

  String? get selectedDayError {
    return selectedDays.isEmpty
        ? 'Es muss mind. ein Tag ausgewählt sein.'
        : null;
  }

  // Can go to second page
  bool get canGoToThirdPage {
    if (isRepeating) {
      final hasValidDates =
          startDate != null && endDate != null && startDate!.isBefore(endDate!);

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
