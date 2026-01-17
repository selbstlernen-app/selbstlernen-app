import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/goals_with_tasks_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:uuid/uuid.dart';

class TopDownPage extends ConsumerStatefulWidget {
  const TopDownPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<TopDownPage> createState() => _TopDownPageState();
}

class _TopDownPageState extends ConsumerState<TopDownPage> {
  final TextEditingController _taskController = TextEditingController();

  Set<String> expandedGoalIds = <String>{};
  static const String ungroupedTaskGoalId = '__ungrouped__';

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  String _getButtonText(AddSessionState state) {
    // Check if any goal has tasks
    final hasAnyTasks = state.goals.any(
      (GoalModel goal) => state.tasksForGoal(goal.id!).isNotEmpty,
    );
    return hasAnyTasks ? 'Weiter' : 'Überspringen';
  }

  void _addTaskToGoal({required GoalModel goal}) {
    final taskText = _taskController.text.trim();
    if (taskText.isEmpty) return;

    final state = ref.read(addSessionViewModelProvider);

    // Check for duplicates
    if (state
        .tasksForGoal(goal.id!)
        .any((TaskModel task) => task.title == taskText)) {
      return;
    }

    ref
        .read(addSessionViewModelProvider.notifier)
        .addTaskToGoal(
          TaskModel(
            id: const Uuid().v4(),
            title: taskText,
            goalId: goal.id != ungroupedTaskGoalId ? goal.id : null,
            keptForFutureSessions: true,
          ),
          goal.id != ungroupedTaskGoalId ? goal.id : null,
        );

    _taskController.clear();

    setState(() {
      expandedGoalIds.add(goal.id!);
    });
  }

  void _toggleGoalExpansion(String goalId) {
    setState(() {
      if (expandedGoalIds.contains(goalId)) {
        expandedGoalIds.remove(goalId);
      } else {
        expandedGoalIds
          ..clear()
          ..add(goalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    const ungroupedTaskGoal = GoalModel(
      id: ungroupedTaskGoalId,
      title: 'Sonstige Aufgaben',
      keptForFutureSessions: false,
    );
    final goalsToMap = [...state.goals, ungroupedTaskGoal];

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ziele aufbrechen',
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.xsmall),
                Text(
                  '''Erstelle zusätzliche Aufgaben, die dir beim Erreichen deiner Ziele helfen.'''
                  ''' Du kannst diesen Schritt auch vorerst überspringen.''',
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(),

                ...goalsToMap.map((GoalModel goal) {
                  final state = ref.watch(addSessionViewModelProvider);
                  if (goal.id == ungroupedTaskGoalId) {}

                  return GoalWithTasksCard(
                    goal: goal,
                    isExpanded: expandedGoalIds.contains(goal.id),
                    onToggleExpand: () => _toggleGoalExpansion(goal.id!),
                    onAddTask: () => _addTaskToGoal(goal: goal),
                    tasksForGoal: goal.id == ungroupedTaskGoalId
                        ? state.ungroupedTasks
                        : state.tasksForGoal(goal.id!),
                    taskController: _taskController,
                  );
                }),
              ],
            ),
          ),
        ),
        // Navigation button
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: _getButtonText(state),
            onPressed: () => widget.navigateForward(),
          ),
        ),
      ],
    );
  }
}
