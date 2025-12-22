import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/instance/get_or_create_instance_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/screens/add_session/validators/add_session_validator.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

part 'add_session_view_model.g.dart';

@riverpod
class AddSessionViewModel extends _$AddSessionViewModel {
  late final GetOrCreateInstanceUseCase _getOrCreateInstanceUseCase;
  late final ManageGoalUseCase _manageGoalUseCase;
  late final ManageTasksUseCase _manageTasksUseCase;

  @override
  AddSessionState build() {
    _getOrCreateInstanceUseCase = ref.watch(getOrCreateInstanceUseCaseProvider);
    _manageGoalUseCase = ref.watch(manageGoalUseCaseProvider);
    _manageTasksUseCase = ref.watch(manageTasksUseCaseProvider);

    return const AddSessionState();
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

  void setGoals({required bool setGoals}) {
    state = state.copyWith(setGoals: setGoals);
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

  // Goals and tasks
  void addGoal(GoalModel goal) {
    state = state.copyWith(goals: <GoalModel>[...state.goals, goal]);
  }

  void addTask(TaskModel task) {
    state = state.copyWith(tasks: <TaskModel>[...state.tasks, task]);
  }

  void removeGoal(int index) {
    final goal = state.goals[index];
    // If in edit mode, mark for deletion
    // Only if not just newly created goal (invalid id)
    if (state.isEditMode && int.tryParse(goal.id!) != null) {
      state = state.copyWith(
        goalIdsToDelete: [
          ...state.goalIdsToDelete,
          goal.id!,
        ],
      );
    }
    final goals = [...state.goals]..removeAt(index);
    state = state.copyWith(goals: goals);
  }

  void removeTask(int index) {
    final task = state.tasks[index];
    // If in edit mode, mark for deletion
    // Only if not just newly created task (invalid id)
    if (state.isEditMode && int.tryParse(task.id!) != null) {
      state = state.copyWith(
        taskIdsToDelete: [
          ...state.taskIdsToDelete,
          task.id!,
        ],
      );
    }
    final tasks = [...state.tasks]..removeAt(index);
    state = state.copyWith(tasks: tasks);
  }

  // Creates a task directly linked to a goal
  void addTaskToGoal(TaskModel task, String? goalId) {
    final taskWithGoal = task.copyWith(goalId: goalId);
    state = state.copyWith(tasks: <TaskModel>[...state.tasks, taskWithGoal]);
  }

  // Task is udpated and linked to a goal
  void linkTaskToGoal(int taskIndex, String goalId) {
    final tasks = List<TaskModel>.from(state.tasks);
    final task = tasks[taskIndex];

    tasks[taskIndex] = task.copyWith(goalId: goalId);

    state = state.copyWith(tasks: tasks);
  }

  void addStrategy(String strategy) {
    if (state.learningStrategies.contains(strategy)) return;

    state = state.copyWith(
      learningStrategies: <String>[...state.learningStrategies, strategy],
      // Add to available strategies if not already included
      availableStrategies: state.availableStrategies.contains(strategy)
          ? state.availableStrategies
          : <String>[...state.availableStrategies, strategy],
    );
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

  void setPomodoroSettings({
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
      hasFreetextPrompt: freetext ?? state.hasFreetextPrompt,
    );
  }

  // Initialization (if in edit mode)
  void initializeState(FullSessionModel fullSessionModel) {
    final session = fullSessionModel.session;
    final hasUngroupedTasks = fullSessionModel.tasks.any(
      (TaskModel task) => task.goalId == null,
    );

    state = state.copyWith(
      sessionId: session.id,
      isEditMode: session.id != null,
      title: session.title,
      isRepeating: session.isRepeating,
      startDate: session.isRepeating ? session.startDate : null,
      endDate: session.isRepeating ? session.endDate : null,
      selectedDays: session.isRepeating ? session.selectedDays : [],
      setGoals: !hasUngroupedTasks,
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
      hasFreetextPrompt: session.hasFreetextPrompt,
    );
  }

  bool validateAll() {
    final titleErr = AddSessionValidator.validateTitle(state.title);
    final dateErr = AddSessionValidator.validateDate(
      startDate: state.startDate,
      isRepeating: state.isRepeating,
      endDate: state.endDate,
    );
    final goalError = AddSessionValidator.validateGoals(
      setGoals: state.setGoals,
      goals: state.goals,
      tasks: state.tasks,
    );
    final daysErr = AddSessionValidator.validateDays(
      state.selectedDays,
      isRepeating: state.isRepeating,
    );

    state = state.copyWith(
      titleError: titleErr,
      dateError: dateErr,
      selectedDaysError: daysErr,
      goalsError: goalError,
    );

    return titleErr == null &&
        dateErr == null &&
        daysErr == null &&
        goalError == null;
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

    // Must have either goals or tasks
    final hasGoals = state.setGoals && state.goals.isNotEmpty;
    final hasTasks = !state.setGoals && state.tasks.isNotEmpty;

    return hasGoals || hasTasks;
  }

  // Update session info
  Future<void> updateSession() async {
    if (!validateAll()) {
      throw Exception('Bitte fülle alle Felder korrekt aus!');
    }

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
    if (!validateAll()) {
      throw Exception('Bitte fülle alle Felder korrekt aus!');
    }

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
    if (!validateAll()) {
      throw Exception('Bitte fülle alle Felder korrekt aus!');
    }

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
      selectedDays: state.selectedDays,
      learningStrategies: state.learningStrategies,
      focusTimeMin: state.focusTimeMin,
      breakTimeMin: state.breakTimeMin,
      longBreakTimeMin: state.longBreakTimeMin,
      focusPhases: state.focusPhases,
      hasFocusPrompt: state.hasFocusPrompt,
      focusPromptInterval: state.focusPromptInterval,
      showFocusPromptAlways: state.showFocusPromptAlways,
      hasFreetextPrompt: state.hasFreetextPrompt,
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
