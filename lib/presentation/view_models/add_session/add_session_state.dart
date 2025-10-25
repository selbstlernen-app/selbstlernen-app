import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/task_model.dart';

part 'add_session_state.freezed.dart';

@freezed
abstract class AddSessionState with _$AddSessionState {
  const AddSessionState._();

  const factory AddSessionState({
    @Default('') String title,
    @Default(false) bool isRepeating,
    @Default(true) bool setBigGoals,
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
    @Default(true) bool isPomodoro,
    @Default(60) int totalTimeMin,
    int? focusTimeMin,
    int? breakTimeMin,
    int? longBreakTimeMin,
    int? cyclesBeforeLongBreak,

    // Prompts
    @Default(false) bool hasFocusPrompt,
    @Default(false) bool hasMoodPrompt,
    @Default(false) bool hasFreetextPrompt,

    //Validation fields
    String? titleError,
    String? startDateError,
    String? endDateError,
    String? selectedDaysError,
  }) = _AddSessionState;

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();
}
