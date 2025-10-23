import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/task_model.dart';
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
    state = state.copyWith(title: title);
  }

  void setIsRepeating(bool isRepeating) {
    state = state.copyWith(isRepeating: isRepeating);
  }

  void setSetBigGoals(bool setBigGoals) {
    state = state.copyWith(setBigGoals: setBigGoals);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
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

  // Goals and tasks
  void addGoal(GoalModel goal) {
    state = state.copyWith(goals: [...state.goals, goal]);
  }

  void removeGoal(int index) {
    final goals = List<GoalModel>.from(state.goals);
    goals.removeAt(index);
    state = state.copyWith(goals: goals);
  }

  void addTask(TaskModel task) {
    state = state.copyWith(tasks: [...state.tasks, task]);
  }

  void removeTask(int index) {
    final tasks = List<TaskModel>.from(state.tasks);
    tasks.removeAt(index);
    state = state.copyWith(tasks: tasks);
  }

  // Creates a task directly linked to a goal
  void addTaskToGoal(TaskModel task, String goalId) {
    final taskWithGoal = task.copyWith(goalId: goalId);

    state = state.copyWith(tasks: [...state.tasks, taskWithGoal]);
  }

  // Task is udpated and linked to a goal
  void linkTaskToGoal(int taskIndex, String goalId) {
    final tasks = List<TaskModel>.from(state.tasks);
    final task = tasks[taskIndex];

    tasks[taskIndex] = task.copyWith(goalId: goalId);

    state = state.copyWith(tasks: tasks);
  }

  void toggleStrategy(String strategy) {
    final strategies = List<String>.from(state.learningStrategies);
    if (strategies.contains(strategy)) {
      strategies.remove(strategy);
    } else {
      strategies.add(strategy);
    }
    state = state.copyWith(learningStrategies: strategies);
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
  }) {
    state = state.copyWith(
      focusTimeMin: focusTime ?? state.focusTimeMin,
      breakTimeMin: breakTime ?? state.breakTimeMin,
      longBreakTimeMin: longBreakTime ?? state.longBreakTimeMin,
      cyclesBeforeLongBreak: cycles ?? state.cyclesBeforeLongBreak,
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
  String? validateTitle() {
    if (state.title.trim().isEmpty) {
      return 'Titel kann nicht leer sein';
    }
    if (state.title.length < 3) {
      return 'Titel muss mind. 3 Charaktere lang sein';
    }
    return null;
  }

  String? validateDates() {
    if (state.isRepeating && state.startDate == null) {
      return 'Startdatum muss gegeben sein';
    }
    if (state.isRepeating && state.endDate == null) {
      return 'Enddatum muss gegeben sein';
    }
    if (state.endDate != null && state.endDate!.isBefore(state.startDate!)) {
      return 'Enddatum kann nicht kleiner als Startdatum sein';
    }
    return null;
  }

  bool canSubmit() {
    return validateTitle() == null &&
        validateDates() == null &&
        // Have at least one goal or task defined
        ((state.goals.isNotEmpty && state.setBigGoals) ||
            (!state.setBigGoals && state.tasks.isNotEmpty));
  }

  // Save all info
  Future<void> createSession() async {
    // Final check before submitting
    if (!canSubmit()) {
      throw Exception('Please complete all required fields');
    }

    final sessionUseCase = ref.read(createSessionUseCaseProvider);

    final session = _stateToSessionModel(state);
    int sessionId = await sessionUseCase.call(session);

    if (state.goals.isNotEmpty && state.setBigGoals) {
      final goalUseCase = ref.read(createGoalsUseCaseProvider);
      for (GoalModel goal in state.goals) {
        GoalModel addGoal = goal.copyWith(sessionId: sessionId.toString());
        goalUseCase.call(addGoal);
      }
    }

    if (state.tasks.isNotEmpty && !state.setBigGoals) {
      final taskUseCase = ref.read(createTasksUseCaseProvider);
      for (TaskModel task in state.tasks) {
        TaskModel addTask = task.copyWith(sessionId: sessionId.toString());
        taskUseCase.call(addTask);
      }
    }
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
      hasFocusPrompt: state.hasFocusPrompt,
      hasMoodPrompt: state.hasMoodPrompt,
      hasFreetextPrompt: state.hasFreetextPrompt,
    );
  }
}
