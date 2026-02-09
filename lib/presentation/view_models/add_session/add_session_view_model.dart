import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/providers.dart';

part 'add_session_view_model.g.dart';

@Riverpod(keepAlive: true)
class AddSessionViewModel extends _$AddSessionViewModel {
  @override
  AddSessionState build() {
    _listenToDataStreams();

    return AddSessionState(
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  void _listenToDataStreams() {
    // Only update the learning strat field on any updates; do NOT trigger whole rebuild
    ref.listen(learningStrategiesStreamProvider, (previous, next) {
      next.whenData((strategies) {
        state = state.copyWith(
          availableStrategies: strategies,
          isLoading: false,
        );
      });
    });
  }

  // -- Setters --

  void setTitle(String title) {
    state = state.copyWith(title: title);
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
    );
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(
      endDate: date,
    );
  }

  void toggleDay(int day) {
    final days = List<int>.from(state.selectedDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    state = state.copyWith(selectedDays: days);
  }

  void setPlannedTime(TimeOfDay plannedTime) {
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
    int? pomodoroPhases,
  }) {
    state = state.copyWith(
      focusTimeMin: focusTime ?? state.focusTimeMin,
      breakTimeMin: breakTime ?? state.breakTimeMin,
      pomodoroPhases: pomodoroPhases ?? state.pomodoroPhases,
    );
  }

  void setPrompts({
    bool? focus,
    int? focusPromptInterval,
    bool? showFocusPromptAlways,
  }) {
    state = state.copyWith(
      hasFocusPrompt: focus ?? state.hasFocusPrompt,
      focusPromptInterval: focusPromptInterval ?? state.focusPromptInterval,
      showFocusPromptAlways:
          showFocusPromptAlways ?? state.showFocusPromptAlways,
    );
  }

  // -- Actions --

  // Initalize state for edit mode
  void initializeState(FullSessionModel fullSessionModel) {
    state = AddSessionState.fromModel(
      fullSession: fullSessionModel,
      existingStrategies: state.availableStrategies,
    );
  }

  // Save or update the session depending on edit mode
  Future<void> handleSaveSession() async {
    final session = _stateToSessionModel(state);
    final service = ref.read(addSessionServiceProvider);

    if (state.isEditMode) {
      await service.updateSessionWithChanges(
        sessionId: int.parse(state.sessionId!),
        session: session,
        goalsToUpdate: state.goals,
        tasksToUpdate: state.tasks,
        goalIdsToDelete: state.goalIdsToDelete,
        taskIdsToDelete: state.taskIdsToDelete,
      );
    } else {
      await service.createSessionWithGoalsAndTasks(
        session: session,
        goals: state.goals,
        tasks: state.tasks,
      );
    }
    resetFields();
  }

  Future<SessionInstanceModel> handleStartSession() async {
    final service = ref.read(addSessionServiceProvider);
    final session = _stateToSessionModel(state);
    if (state.isEditMode) {
      await service.updateSessionWithChanges(
        sessionId: int.parse(state.sessionId!),
        session: session,
        goalsToUpdate: state.goals,
        tasksToUpdate: state.tasks,
        goalIdsToDelete: state.goalIdsToDelete,
        taskIdsToDelete: state.taskIdsToDelete,
      );
    } else {
      final sessionId = await service.createSessionWithGoalsAndTasks(
        session: session,
        goals: state.goals,
        tasks: state.tasks,
      );

      state = state.copyWith(sessionId: sessionId.toString());
    }

    final instance = await ref
        .read(getOrCreateInstanceUseCaseProvider)
        .call(
          sessionId: int.parse(state.sessionId!),
          date: DateTime.now(),
        );

    return instance;
  }

  void resetFields() {
    // Returns default state, with exception of saved available strategies
    state = const AddSessionState().copyWith(
      availableStrategies: state.availableStrategies,
    );
  }

  SessionModel _stateToSessionModel(AddSessionState state) {
    // In case of simple sessions adapt all other time properties to 0
    final isComplex = state.sessionComplexity == SessionComplexity.advanced;
    return SessionModel(
      title: state.title,
      isRepeating: state.isRepeating,
      startDate: state.startDate,
      endDate: state.endDate,
      plannedTime: state.plannedTime,
      hasNotification: state.enableNotifications,
      complexity: state.sessionComplexity,
      selectedDays: state.selectedDays,
      learningStrategies: state.learningStrategies,
      focusTimeMin: state.focusTimeMin,
      breakTimeMin: isComplex ? state.breakTimeMin : 0,
      pomodoroPhases: isComplex ? state.pomodoroPhases : 0,
      hasFocusPrompt: state.hasFocusPrompt,
      focusPromptInterval: state.focusPromptInterval,
      showFocusPromptAlways: state.showFocusPromptAlways,
    );
  }
}
