import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({
    super.key,
    required this.fullSessionModel,
    required this.instanceId,
  });

  final FullSessionModel fullSessionModel;
  final int instanceId;

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  final TextEditingController _taskController = TextEditingController();
  final ScrollController _goalsScrollController = ScrollController();
  String? _expandedGoalId;

  @override
  void dispose() {
    _taskController.dispose();
    _goalsScrollController.dispose();
    super.dispose();
  }

  Future<void> _addTask(String? goalId) async {
    if (_taskController.text.trim().isEmpty) return;

    await ref
        .read(activeSessionViewModelProvider(widget.instanceId).notifier)
        .addTask(
          _taskController.text.trim(),
          goalId: goalId, // if task should belong to some goal; else null
        );

    _taskController.clear();

    // Scroll down when general task
    if (goalId == null) {
      await _goalsScrollController.animateTo(
        _goalsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ActiveSessionState state = ref.watch(
      activeSessionViewModelProvider(widget.instanceId),
    );
    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    final List<GoalModel> goals = state.fullSession!.goals;
    final List<TaskModel> ungroupedTasks = state.ungroupedTasks;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Ziele & Aufgaben',
                  style: context.textTheme.headlineMedium,
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.colorScheme.primary,
                  child: IconButton(
                    onPressed: () => viewModel.toggleEditMode(),
                    icon: state.isEditMode
                        ? const Icon(Icons.edit_off_outlined)
                        : const Icon(Icons.edit_outlined),
                  ),
                ),
              ],
            ),
            const VerticalSpace(size: SpaceSize.small),

            Expanded(
              child: ListView(
                controller: _goalsScrollController,
                children: <Widget>[
                  // Existing goals with tasks
                  ...goals.map((GoalModel goal) {
                    final List<TaskModel> relatedTasks = state.tasksForGoal(
                      goal.id!,
                    );

                    return _GoalWithTasksItem(
                      goal: goal,
                      tasks: relatedTasks,
                      isExpanded: _expandedGoalId == goal.id,
                      onExpandChanged: (bool expanded) {
                        setState(() {
                          _expandedGoalId = expanded ? goal.id : null;
                        });
                      },
                      completedGoalIds: state.completedGoalIds,
                      completedTaskIds: state.completedTaskIds,
                      onGoalToggle: (String goalId) =>
                          viewModel.toggleGoalCompletion(goalId),
                      onTaskToggle: (String taskId) =>
                          viewModel.toggleTaskCompletion(taskId),
                      onAddTask: () => _addTask(goal.id!),
                      isEditMode: state.isEditMode,
                      controller: _taskController,
                    );
                  }),

                  // Divider
                  if (goals.isNotEmpty &&
                      ungroupedTasks.isNotEmpty) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.xsmall),
                    Divider(color: context.colorScheme.tertiary, thickness: 4),
                    const VerticalSpace(size: SpaceSize.xsmall),
                  ],

                  // Ungrouped tasks
                  ...ungroupedTasks.map((TaskModel task) {
                    return _TaskItem(
                      task: task,
                      isCompleted: state.completedTaskIds.contains(task.id),
                      onToggle: () => viewModel.toggleTaskCompletion(task.id!),
                    );
                  }),
                ],
              ),
            ),

            if (state.isEditMode && _expandedGoalId == null) ...<Widget>[
              const VerticalSpace(size: SpaceSize.small),
              CustomAddItemField(
                controller: _taskController,
                hintText: "Neue Aufgabe...",
                onSubmitted: () => _addTask(null), // No goal ID = general task
                onPressed: () => _addTask(null),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Goal item with expandable tasks
class _GoalWithTasksItem extends StatelessWidget {
  const _GoalWithTasksItem({
    required this.goal,
    required this.tasks,
    required this.completedGoalIds,
    required this.completedTaskIds,
    required this.onGoalToggle,
    required this.onTaskToggle,
    required this.onAddTask,
    required this.controller,
    required this.isEditMode,
    required this.isExpanded,
    required this.onExpandChanged,
  });

  final GoalModel goal;
  final List<TaskModel> tasks;
  final Set<String> completedGoalIds;
  final Set<String> completedTaskIds;
  final Function(String) onGoalToggle;
  final Function(String) onTaskToggle;
  final VoidCallback onAddTask;
  final bool isEditMode;
  final TextEditingController controller;
  final bool isExpanded;
  final ValueChanged<bool> onExpandChanged;

  @override
  Widget build(BuildContext context) {
    final bool isGoalCompleted = completedGoalIds.contains(goal.id);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpandChanged,
        tilePadding: const EdgeInsets.symmetric(vertical: 4.0),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: Checkbox(
          value: isGoalCompleted,
          onChanged: (_) => onGoalToggle(goal.id!),
        ),
        showTrailingIcon: true,
        title: Text(
          goal.title,
          style: context.textTheme.titleLarge!.copyWith(
            decoration: isGoalCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: tasks.isNotEmpty
            ? Text(
                '${tasks.where((TaskModel t) => completedTaskIds.contains(t.id)).length}/${tasks.length} Aufgaben erledigt',
                style: context.textTheme.bodyMedium,
              )
            : null,
        children: <Widget>[
          ...tasks.map((TaskModel task) {
            return _TaskItem(
              task: task,
              isCompleted: completedTaskIds.contains(task.id),
              onToggle: () => onTaskToggle(task.id!),
              isSubtask: true,
            );
          }),

          if (isEditMode) // if general isEditMode is off, be able to add according to the
          ...<Widget>[
            const VerticalSpace(size: SpaceSize.small),
            CustomAddItemField(
              controller: controller,
              hintText: "Aufgabe für ${goal.title}...",
              onSubmitted: () => onAddTask(),
              onPressed: onAddTask,
            ),
          ],
        ],
      ),
    );
  }
}

// Task item
class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.task,
    required this.isCompleted,
    required this.onToggle,
    this.isSubtask = false,
  });

  final TaskModel task;
  final bool isCompleted;
  final VoidCallback onToggle;
  final bool isSubtask;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(4.0),
      leading: Checkbox(value: isCompleted, onChanged: (_) => onToggle()),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: onToggle,
    );
  }
}
