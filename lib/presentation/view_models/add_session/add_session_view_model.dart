import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/services/add_session_service.dart';
import 'package:srl_app/domain/usecases/instance/get_or_create_instance_use_case.dart';
import 'package:srl_app/presentation/validators/add_session_validator.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

part 'add_session_view_model.g.dart';

@riverpod
class AddSessionViewModel extends _$AddSessionViewModel {
  late final GetOrCreateInstanceUseCase _getOrCreateInstanceUseCase;

  @override
  AddSessionState build() {
    _getOrCreateInstanceUseCase = ref.watch(getOrCreateInstanceUseCaseProvider);
    return const AddSessionState();
  }

  // Basic info
  void setTitle(String title) {
    state = state.copyWith(
      title: title,
      titleError: AddSessionValidator.validateTitle(title),
    );
  }

  void setIsRepeating(bool isRepeating) {
    state = state.copyWith(isRepeating: isRepeating);
  }

  void setGoals(bool setGoals) {
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
    final List<int> days = List<int>.from(state.selectedDays);
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

  void removeGoal(int index) {
    final List<GoalModel> goals = List<GoalModel>.from(state.goals);
    goals.removeAt(index);
    state = state.copyWith(goals: goals);
  }

  void addTask(TaskModel task) {
    state = state.copyWith(tasks: <TaskModel>[...state.tasks, task]);
  }

  void removeTask(int index) {
    final List<TaskModel> tasks = List<TaskModel>.from(state.tasks);
    tasks.removeAt(index);
    state = state.copyWith(tasks: tasks);
  }

  void markTaskIdForDeletion(String index) {
    state = state.copyWith(
      taskIdsToDelete: <String>[...state.taskIdsToDelete, index],
    );
  }

  // Marks goals and associated tasks for deletion
  void markGoalForDeletion(String goalId) {
    final List<String> associatedTaskIds = state.tasks
        .where((TaskModel task) => task.goalId == goalId && task.id != null)
        .map((TaskModel task) => task.id!)
        .toList();

    state = state.copyWith(
      goalIdsToDelete: <String>[...state.goalIdsToDelete, goalId],
      taskIdsToDelete: <String>[...state.taskIdsToDelete, ...associatedTaskIds],
    );
  }

  // Creates a task directly linked to a goal
  void addTaskToGoal(TaskModel task, String goalId) {
    final TaskModel taskWithGoal = task.copyWith(goalId: goalId);

    state = state.copyWith(tasks: <TaskModel>[...state.tasks, taskWithGoal]);
  }

  // Task is udpated and linked to a goal
  void linkTaskToGoal(int taskIndex, String goalId) {
    final List<TaskModel> tasks = List<TaskModel>.from(state.tasks);
    final TaskModel task = tasks[taskIndex];

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
    final List<String> updated = List<String>.from(state.learningStrategies);

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
    SessionModel session = fullSessionModel.session;
    bool hasUngroupedTasks = fullSessionModel.tasks.any(
      (TaskModel task) => task.goalId == null,
    );

    if (session.isRepeating) {
      state = state.copyWith(
        startDate: session.startDate,
        endDate: session.endDate,
        selectedDays: session.selectedDays,
      );
    }

    state = state.copyWith(
      sessionId: session.id,
      title: session.title,
      isRepeating: session.isRepeating,
      setGoals:
          !hasUngroupedTasks, // if no ungrouped tasks, we had set goals to true
      goals: fullSessionModel.goals,
      tasks: fullSessionModel.tasks,
      learningStrategies: session.learningStrategies,
      focusTimeMin: session.focusTimeMin,
      breakTimeMin: session.breakTimeMin,
      longBreakTimeMin: session.longBreakTimeMin,
      focusPhases: session.focusPhases,
      hasFocusPrompt: session.hasFocusPrompt,
      hasFreetextPrompt: session.hasFreetextPrompt,
    );
  }

  bool validateAll() {
    final String? titleErr = AddSessionValidator.validateTitle(state.title);
    final String? dateErr = AddSessionValidator.validateDate(
      startDate: state.startDate,
      isRepeating: state.isRepeating,
      endDate: state.endDate,
    );
    final String? goalError = AddSessionValidator.validateGoals(
      setGoals: state.setGoals,
      goals: state.goals,
      tasks: state.tasks,
    );
    final String? daysErr = AddSessionValidator.validateDays(
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
    return state.titleError == null &&
        (state.isRepeating
            ? (state.startDate != null &&
                  state.endDate != null &&
                  state.selectedDays.isNotEmpty == true)
            : true) &&
        ((state.goals.isNotEmpty && state.setGoals) ||
            (!state.setGoals && state.tasks.isNotEmpty));
  }

  // Update session info
  Future<void> updateSession() async {
    final AddSessionService service = ref.read(addSessionServiceProvider);
    final SessionModel session = _stateToSessionModel(state);

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

    final AddSessionService service = ref.read(addSessionServiceProvider);
    final SessionModel session = _stateToSessionModel(state);

    int sessionId = await service.createSessionWithGoalsAndTasks(
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
      hasFreetextPrompt: state.hasFreetextPrompt,
    );
  }

  Future<SessionInstanceModel> startSession(DateTime date) async {
    return await _getOrCreateInstanceUseCase.call(
      sessionId: int.parse(state.sessionId!),
      date: date,
    );
  }
}
