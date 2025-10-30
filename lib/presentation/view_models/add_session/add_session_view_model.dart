import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/usecases/create_goals_use_case.dart';
import 'package:srl_app/domain/usecases/create_session_use_case.dart';
import 'package:srl_app/domain/usecases/create_tasks_use_case.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

part 'add_session_view_model.g.dart';

@riverpod
class AddSessionViewModel extends _$AddSessionViewModel {
  @override
  AddSessionState build() {
    return const AddSessionState();
  }

  // Basic info
  void setTitle(String title) {
    state = state.copyWith(title: title, titleError: _validateTitle(title));
  }

  void setIsRepeating(bool isRepeating) {
    state = state.copyWith(isRepeating: isRepeating);
  }

  void setGoals(bool setGoals) {
    state = state.copyWith(setGoals: setGoals);
    _resetGoalFields();
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(
      startDate: date,
      startDateError: _validateStartDate(date),
    );
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date, endDateError: _validateEndDate(date));
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
      selectedDaysError: _validateDays(days),
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
    final bool isSelected = state.learningStrategies.contains(strategy);

    state = state.copyWith(
      learningStrategies: isSelected
          ? state.learningStrategies.where((String s) => s != strategy).toList()
          : <String>[...state.learningStrategies, strategy],
    );
  }

  void setIsPomodoro(bool isPomodoro) {
    state = state.copyWith(isPomodoro: isPomodoro);
  }

  void setTotalTime(int minutes) {
    state = state.copyWith(totalTimeMin: minutes);
  }

  void setPomodoroSettings({
    int? focusTime,
    int? breakTime,
    int? longBreakTime,
    int? cycles,
    int? totalPomodoros,
  }) {
    state = state.copyWith(
      focusTimeMin: focusTime ?? state.focusTimeMin,
      breakTimeMin: breakTime ?? state.breakTimeMin,
      longBreakTimeMin: longBreakTime ?? state.longBreakTimeMin,
      cyclesBeforeLongBreak: cycles ?? state.cyclesBeforeLongBreak,
      totalPomodoros: totalPomodoros ?? state.totalPomodoros,
    );
  }

  void setPrompts({bool? focus, bool? mood, bool? freetext}) {
    state = state.copyWith(
      hasFocusPrompt: focus ?? state.hasFocusPrompt,
      hasMoodPrompt: mood ?? state.hasMoodPrompt,
      hasFreetextPrompt: freetext ?? state.hasFreetextPrompt,
    );
  }

  // Validation
  String? _validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Titel kann nicht leer sein.';
    }
    if (title.length < 3) {
      return 'Titel muss mind. 3 Charaktere lang sein.';
    }
    return null;
  }

  String? _validateStartDate(DateTime? date) {
    if (!state.isRepeating) {
      return null;
    }
    if (date == null) {
      return 'Startdatum muss gegeben sein.';
    }
    if (state.endDate != null) {
      if (state.endDate!.isBefore(date)) {
        return 'Startdatum muss vor dem Enddatum liegen.';
      }

      if (state.endDate!.isAtSameMomentAs(date)) {
        return 'Start- und Enddatum können nicht am selben Tag sein. Wähle einmalig stattdessen.';
      }
    }
    return null;
  }

  String? _validateEndDate(DateTime? date) {
    if (!state.isRepeating) return null;
    if (date == null) {
      return 'Enddatum muss gegeben sein.';
    }
    if (state.startDate != null) {
      if (date.isBefore(state.startDate!)) {
        return 'Enddatum muss nach dem Startdatum liegen.';
      }

      if (date.isAtSameMomentAs(state.startDate!)) {
        return 'Start- und Enddatum können nicht am selben Tag sein. Wähle einmalig stattdessen.';
      }
    }
    return null;
  }

  String? _validateDays(List<int> selectedDays) {
    if (!state.isRepeating) return null;
    if (selectedDays.isEmpty) {
      return "Es muss mind. ein Tag ausgewählt werden.";
    }
    return null;
  }

  String? _validateGoals({
    required List<GoalModel> goals,
    required List<TaskModel> tasks,
  }) {
    if (state.setGoals && goals.isEmpty) {
      return "Es muss mind. 1 Ziel festgelegt werden.";
    }
    if (!state.setGoals && tasks.isEmpty) {
      return "Es muss mind. 1 Aufgabe festgelegt werden.";
    }
    return null;
  }

  bool validateAll() {
    final String? titleErr = _validateTitle(state.title);
    final String? startErr = _validateStartDate(state.startDate);
    final String? endErr = _validateEndDate(state.endDate);
    final String? goalError = _validateGoals(
      goals: state.goals,
      tasks: state.tasks,
    );
    final String? daysErr = _validateDays(state.selectedDays);

    // Update state with all errors
    state = state.copyWith(
      titleError: titleErr,
      startDateError: startErr,
      endDateError: endErr,
      selectedDaysError: daysErr,
      goalsError: goalError,
    );

    // Return true only if all validations pass
    return titleErr == null &&
        startErr == null &&
        endErr == null &&
        daysErr == null &&
        ((state.goals.isNotEmpty && state.setGoals) ||
            (!state.setGoals && state.tasks.isNotEmpty));
  }

  bool get isFormValid {
    return state.title.isNotEmpty &&
        (state.isRepeating
            ? (state.startDate != null &&
                  state.endDate != null &&
                  state.selectedDays.isNotEmpty == true)
            : true) &&
        ((state.goals.isNotEmpty && state.setGoals) ||
            (!state.setGoals && state.tasks.isNotEmpty));
  }

  // Save all info
  Future<void> createSession() async {
    // Final check before submitting
    if (!validateAll()) {
      throw Exception('Bitte fülle alle Felder korrekt aus!');
    }

    final CreateSessionUseCase sessionUseCase = ref.read(
      createSessionUseCaseProvider,
    );

    final SessionModel session = _stateToSessionModel(state);
    int sessionId = await sessionUseCase.call(session);

    if (state.goals.isNotEmpty && state.setGoals) {
      final CreateGoalsUseCase goalUseCase = ref.read(
        createGoalsUseCaseProvider,
      );
      for (GoalModel goal in state.goals) {
        GoalModel addGoal = goal.copyWith(sessionId: sessionId.toString());
        await goalUseCase.call(addGoal);
      }
    }

    if (state.tasks.isNotEmpty && !state.setGoals) {
      final CreateTasksUseCase taskUseCase = ref.read(
        createTasksUseCaseProvider,
      );
      for (TaskModel task in state.tasks) {
        TaskModel addTask = task.copyWith(sessionId: sessionId.toString());
        await taskUseCase.call(addTask);
      }
    }

    resetFields();
  }

  void _resetGoalFields() {
    // If we have big goals set, remove any tasks (small goals) for following pages
    if (state.setGoals) {
      state = state.copyWith(tasks: <TaskModel>[]);
    } else {
      // Similarly, if we have set small goals, remove big goals
      state = state.copyWith(goals: <GoalModel>[]);
    }
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
      isPomodoro: state.isPomodoro,
      totalTimeMin: state.totalTimeMin,
      focusTimeMin: state.focusTimeMin,
      breakTimeMin: state.breakTimeMin,
      longBreakTimeMin: state.longBreakTimeMin,
      cyclesBeforeLongBreak: state.cyclesBeforeLongBreak,
      totalPomodoros: state.totalPomodoros,
      hasFocusPrompt: state.hasFocusPrompt,
      hasMoodPrompt: state.hasMoodPrompt,
      hasFreetextPrompt: state.hasFreetextPrompt,
    );
  }
}
