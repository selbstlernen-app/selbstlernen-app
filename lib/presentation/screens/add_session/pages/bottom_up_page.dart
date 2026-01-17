import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/goals_with_tasks_list.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/input_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:uuid/uuid.dart';

class BottomUpPage extends ConsumerStatefulWidget {
  const BottomUpPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomUpPageState();
}

class _BottomUpPageState extends ConsumerState<BottomUpPage> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final List<TaskModel> _selectedTasks = <TaskModel>[];
  final Set<String> expandedGoalIds = <String>{};

  @override
  void dispose() {
    _goalController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _groupTasksTo() {
    final goalTitle = _goalController.text.trim();
    if (goalTitle.isEmpty || _selectedTasks.isEmpty) return;

    const uuid = Uuid();

    final newGoal = GoalModel(
      title: goalTitle,
      id: uuid.v4(),
      keptForFutureSessions: true,
    );

    ref.read(addSessionViewModelProvider.notifier).addGoal(newGoal);

    // Link tasks to newly created goal
    for (final task in _selectedTasks) {
      ref
          .read(addSessionViewModelProvider.notifier)
          .linkTaskToGoal(
            ref.read(addSessionViewModelProvider).tasks.indexOf(task),
            newGoal.id!,
          );
    }

    // Clear selections and expand the new goal!
    setState(() {
      _selectedTasks.clear();
      expandedGoalIds
        ..clear()
        ..add(newGoal.id!);
    });
    _goalController.clear();
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
            goalId: goal.id,
            keptForFutureSessions: true,
          ),
          goal.id,
        );

    _taskController.clear();
    setState(() {
      expandedGoalIds.add(goal.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Aufgaben gruppieren',
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.xsmall),
                Text(
                  '''Gruppiere Aufgaben unter einem Ziel zusammen. Du kannst diesen Schritt auch vorerst überspringen.''',
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(),

                // Ungrouped tasks for selection to goals
                if (state.ungroupedTasks.isNotEmpty) ...<Widget>[
                  Text(
                    'Verfügbare Aufgaben',
                    style: context.textTheme.headlineSmall,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  ...state.ungroupedTasks.map((TaskModel task) {
                    final isSelected = _selectedTasks.any(
                      (TaskModel t) => t.id == task.id,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isSelected
                            ? context.colorScheme.secondary
                            : context.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selectedTasks.removeWhere(
                                (TaskModel t) => t.id == task.id,
                              );
                            } else {
                              _selectedTasks.add(task);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: CustomItemTile(
                              iconSize: 24,
                              isLargeGoal: false,
                              text: task.title,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const VerticalSpace(size: SpaceSize.small),
                ],

                // Create new goal from selected tasks
                if (_selectedTasks.isNotEmpty) ...<Widget>[
                  Text(
                    'Ziel formulieren (${_selectedTasks.length} ausgewählt)',
                    style: context.textTheme.headlineSmall,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  InputList<TaskModel>(
                    markEditMode: state.isEditMode,
                    controller: _goalController,
                    onEnter: _groupTasksTo,
                    isBigGoal: true,
                    items: const <TaskModel>[],
                    hideHeadline: true, // Empty, showing input only
                  ),

                  const VerticalSpace(size: SpaceSize.small),
                ],

                if (state.goals.isNotEmpty) ...<Widget>[
                  Text(
                    'Gruppierte Aufgaben',
                    style: context.textTheme.headlineSmall,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  ...state.goals.map((GoalModel goal) {
                    return GoalWithTasksCard(
                      goal: goal,
                      isExpanded: expandedGoalIds.contains(goal.id),
                      onToggleExpand: () => _toggleGoalExpansion(goal.id!),
                      onAddTask: () => _addTaskToGoal(goal: goal),
                      tasksForGoal: state.tasksForGoal(goal.id!),
                      taskController: _taskController,
                    );
                  }),
                ],
              ],
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: state.goals.isEmpty ? 'Überspringen' : 'Weiter',
            onPressed: () => widget.navigateForward(),
          ),
        ),
      ],
    );
  }
}
