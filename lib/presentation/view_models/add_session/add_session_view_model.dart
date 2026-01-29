import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/manage_learning_strategy_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/notification_service.dart';
import 'package:srl_app/presentation/screens/add_session/validators/add_session_validator.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

part 'add_session_view_model.g.dart';

@riverpod
class AddSessionViewModel extends _$AddSessionViewModel {
  late final GetOrCreateInstanceUseCase _getOrCreateInstanceUseCase;
  late final ManageLearningStrategyUseCase _manageLearningStrategyUseCase;

  StreamSubscription<dynamic>? _strategySubscription;

  @override
  AddSessionState build() {
    _getOrCreateInstanceUseCase = ref.watch(getOrCreateInstanceUseCaseProvider);
    _manageLearningStrategyUseCase = ref.watch(
      manageLearningStrategyUseCaseProvider,
    );

    ref.onDispose(() {
      unawaited(_strategySubscription?.cancel());
    });

    _subscribe();

    return const AddSessionState();
  }

  void _subscribe() {
    _strategySubscription = _manageLearningStrategyUseCase
        .watchLearningStrategies()
        .listen(
          (List<LearningStrategyModel> strategies) {
            state = state.copyWith(
              availableStrategies: strategies,
              isLoading: false,
            );
          },
          onError: (dynamic error) {
            state = state.copyWith(isLoading: false);
          },
        );
  }

  // Basic info
  void setTitle(String title) {
    state = state.copyWith(
      title: title,
      titleError: AddSessionValidator.validateTitle(title),
    );
  }

  void setIsRepeating({required bool isRepeating}) {
    state = state.copyWith(isRepeating: isRepeating);
  }

  void setSessionComplexity({required SessionComplexity complexity}) {
    state = state.copyWith(sessionComplexity: complexity);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(
      startDate: date,
      dateError: AddSessionValidator.validateDate(
        isRepeating: state.isRepeating,
        startDate: date,
        endDate: state.endDate,
      ),
    );
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(
      endDate: date,
      dateError: AddSessionValidator.validateDate(
        startDate: state.startDate,
        isRepeating: state.isRepeating,
        endDate: date,
      ),
    );
  }

  void toggleDay(int day) {
    final days = List<int>.from(state.selectedDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    state = state.copyWith(
      selectedDays: days,
      selectedDaysError: AddSessionValidator.validateDays(
        isRepeating: state.isRepeating,
        days,
      ),
    );
  }

  void updateTime(TimeOfDay plannedTime) {
    state = state.copyWith(plannedTime: plannedTime);
  }

  Future<void> enableNotifications({required bool isEnabled}) async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      state = state.copyWith(enableNotifications: isEnabled);
    } else {
      await NotificationService().openNotificationSettings();
    }
  }

  // Goals and tasks
  void addGoal(GoalModel goal) {
    state = state.copyWith(goals: <GoalModel>[...state.goals, goal]);
  }

  // Check if no id or UUID is given
  bool _isPersistentId(String? id) {
    if (id == null) return false;
    return int.tryParse(id) != null;
  }

  void removeGoalById(String goalId) {
    if (state.isEditMode && _isPersistentId(goalId)) {
      state = state.copyWith(
        goalIdsToDelete: {...state.goalIdsToDelete, goalId},
      );
    }

    state = state.copyWith(
      goals: state.goals.where((g) => g.id != goalId).toList(),
    );
  }

  void removeTask(String taskId) {
    if (state.isEditMode && _isPersistentId(taskId)) {
      state = state.copyWith(
        taskIdsToDelete: {...state.taskIdsToDelete, taskId},
      );
    }

    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != taskId).toList(),
    );
  }

  // Creates a task directly linked to a goal
  void addTaskToGoal(TaskModel task, String? goalId) {
    final taskWithGoal = task.copyWith(goalId: goalId);
    state = state.copyWith(tasks: [...state.tasks, taskWithGoal]);
  }

  void toggleStrategy(String strategy) {
    final updated = List<String>.from(state.learningStrategies);

    if (updated.contains(strategy)) {
      updated.remove(strategy);
    } else {
      updated.add(strategy);
    }

    state = state.copyWith(learningStrategies: updated);
  }

  void setTimerSettings({
    int? focusTime,
    int? breakTime,
    int? longBreakTime,
    int? focusPhases,
  }) {
    state = state.copyWith(
      focusTimeMin: focusTime ?? state.focusTimeMin,
      breakTimeMin: breakTime ?? state.breakTimeMin,
      longBreakTimeMin: longBreakTime ?? state.longBreakTimeMin,
      focusPhases: focusPhases ?? state.focusPhases,
    );
  }

  void setPrompts({
    bool? focus,
    int? focusPromptInterval,
    bool? showFocusPromptAlways,
    bool? freetext,
  }) {
    state = state.copyWith(
      hasFocusPrompt: focus ?? state.hasFocusPrompt,
      focusPromptInterval: focusPromptInterval ?? state.focusPromptInterval,
      showFocusPromptAlways:
          showFocusPromptAlways ?? state.showFocusPromptAlways,
    );
  }

  // Initialization (if in edit mode)
  void initializeState(FullSessionModel fullSessionModel) {
    final session = fullSessionModel.session;

    state = state.copyWith(
      sessionId: session.id,
      isEditMode: session.id != null,
      title: session.title,
      isRepeating: session.isRepeating,
      startDate: session.isRepeating ? session.startDate : null,
      endDate: session.isRepeating ? session.endDate : null,
      selectedDays: session.isRepeating ? session.selectedDays : [],

      goals: fullSessionModel.goals,
      tasks: fullSessionModel.tasks,
      learningStrategies: session.learningStrategies,
      focusTimeMin: session.focusTimeMin,
      breakTimeMin: session.breakTimeMin,
      longBreakTimeMin: session.longBreakTimeMin,
      focusPhases: session.focusPhases,
      hasFocusPrompt: session.hasFocusPrompt,
      focusPromptInterval: session.focusPromptInterval,
      showFocusPromptAlways: session.showFocusPromptAlways,
    );
  }

  bool get isFormValid {
    // Title must be valid
    if (state.titleError != null) return false;

    // If repeating, must have date range and selected days
    if (state.isRepeating) {
      if (state.startDate == null ||
          state.endDate == null ||
          state.selectedDays.isEmpty) {
        return false;
      }
    }

    // Must have some goal or task
    return state.goals.isNotEmpty || state.tasks.isNotEmpty;
  }

  // Update session info
  Future<void> updateSession() async {
    final service = ref.read(addSessionServiceProvider);
    final session = _stateToSessionModel(state);

    await service.updateSessionWithChanges(
      sessionId: int.parse(state.sessionId!),
      session: session,
      goalsToUpdate: state.goals,
      tasksToUpdate: state.tasks,
      goalIdsToDelete: state.goalIdsToDelete,
      taskIdsToDelete: state.taskIdsToDelete,
    );
  }

  Future<void> updateSessionAndReset() async {
    final service = ref.read(addSessionServiceProvider);
    final session = _stateToSessionModel(state);

    await service.updateSessionWithChanges(
      sessionId: int.parse(state.sessionId!),
      session: session,
      goalsToUpdate: state.goals,
      tasksToUpdate: state.tasks,
      goalIdsToDelete: state.goalIdsToDelete,
      taskIdsToDelete: state.taskIdsToDelete,
    );

    resetFields();
  }

  // Save all info
  Future<void> createSession() async {
    final service = ref.read(addSessionServiceProvider);
    final session = _stateToSessionModel(state);

    final sessionId = await service.createSessionWithGoalsAndTasks(
      session: session,
      goals: state.goals,
      tasks: state.tasks,
    );

    state = state.copyWith(sessionId: sessionId.toString());
  }

  void resetFields() {
    // returns default state, with exception of saved available strategies
    state = const AddSessionState().copyWith(
      availableStrategies: state.availableStrategies,
    );
  }

  SessionModel _stateToSessionModel(AddSessionState state) {
    return SessionModel(
      title: state.title,
      isRepeating: state.isRepeating,
      startDate: state.startDate,
      endDate: state.endDate,
      plannedTime: state.plannedTime,
      complexity: state.sessionComplexity,
      selectedDays: state.selectedDays,
      learningStrategies: state.learningStrategies,
      focusTimeMin: state.focusTimeMin,
      breakTimeMin: state.breakTimeMin,
      longBreakTimeMin: state.longBreakTimeMin,
      focusPhases: state.focusPhases,
      hasFocusPrompt: state.hasFocusPrompt,
      focusPromptInterval: state.focusPromptInterval,
      showFocusPromptAlways: state.showFocusPromptAlways,
    );
  }

  Future<SessionInstanceModel> startSession() async {
    final now = DateTime.now();
    final instance = await _getOrCreateInstanceUseCase.call(
      sessionId: int.parse(state.sessionId!),
      date: now,
    );

    resetFields();
    return instance;
  }
}
