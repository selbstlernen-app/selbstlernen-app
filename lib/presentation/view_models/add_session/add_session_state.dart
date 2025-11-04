import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'add_session_state.freezed.dart';

@freezed
abstract class AddSessionState with _$AddSessionState {
  const AddSessionState._();

  const factory AddSessionState({
    @Default('') String title,
    @Default(false) bool isRepeating,
    @Default(true) bool setGoals,
    DateTime? startDate,
    DateTime? endDate,
    @Default(<int>[]) List<int> selectedDays,

    // Goals and tasks
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,

    // Strategies
    @Default(<String>[]) List<String> learningStrategies,
    @Default(<String>[
      'Mind-map erstellen',
      'Mit Freunden besprechen',
      'Notizen machen',
      'Neu-lesen',
      'Wiederholen',
      'Karteikarten erstellen',
    ])
    List<String> availableStrategies,

    // Time
    int? totalTimeMin,
    @Default(25) int focusTimeMin,
    @Default(5) int breakTimeMin,
    @Default(15) int longBreakTimeMin,
    @Default(4) int focusPhases,

    // Prompts
    @Default(false) bool hasFocusPrompt,
    @Default(false) bool hasMoodPrompt,
    @Default(false) bool hasFreetextPrompt,

    //Validation fields
    String? titleError,
    String? startDateError,
    String? endDateError,
    String? selectedDaysError,
    String? goalsError,
  }) = _AddSessionState;

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();

  List<TaskModel> tasksForGoal(String goalId) =>
      tasks.where((TaskModel task) => task.goalId == goalId).toList();

  bool get isTimeValid {
    if (focusTimeMin > 0) return true;
    return false;
  }
}
