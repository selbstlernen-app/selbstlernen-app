import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class GoalsListWidget extends ConsumerStatefulWidget {
  const GoalsListWidget({super.key, required this.instanceId});

  final int instanceId;

  @override
  ConsumerState<GoalsListWidget> createState() => _GoalsListWidgetState();
}

class _GoalsListWidgetState extends ConsumerState<GoalsListWidget> {
  final TextEditingController _taskGoalController = TextEditingController();

  @override
  void dispose() {
    _taskGoalController.dispose();

    super.dispose();
  }

  Future<void> _addTask(String? goalId) async {
    if (_taskGoalController.text.trim().isEmpty) return;

    await ref
        .read(activeSessionViewModelProvider(widget.instanceId).notifier)
        .addTask(
          _taskGoalController.text.trim(),
          goalId: goalId != "0"
              ? goalId
              : null, // for "Sonstige Aufgaben"; has a temp goal model with id 0
        );

    _taskGoalController.clear();
  }

  Future<void> _addGoal() async {
    if (_taskGoalController.text.trim().isEmpty) return;

    await ref
        .read(activeSessionViewModelProvider(widget.instanceId).notifier)
        .addGoal(_taskGoalController.text.trim());

    _taskGoalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ActiveSessionState state = ref.watch(
      activeSessionViewModelProvider(widget.instanceId),
    );
    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    List<GoalModel> goals = List<GoalModel>.from(state.goals);
    List<TaskModel> allTasks = List<TaskModel>.from(state.tasks);

    // Add a temporary goal; with invalid goal id, to add ungrouped tasks
    final GoalModel ungroupedGoal = const GoalModel(
      id: "0",
      title: "Sonstige Aufgaben",
      isCompleted: false,
      keptForFutureSessions: false,
    );
    final List<TaskModel> ungroupedTasks = allTasks
        .where((TaskModel t) => t.goalId == null || t.goalId!.isEmpty)
        .map((TaskModel t) => t.copyWith(goalId: '0'))
        .toList();

    goals = <GoalModel>[...goals, ungroupedGoal];
    allTasks = <TaskModel>[...allTasks, ...ungroupedTasks];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Ziele & Aufgaben', style: context.textTheme.headlineSmall),
            CustomIconButton(
              isActive: state.isEditMode,
              onPressed: viewModel.toggleEditMode,
              icon: !state.isEditMode
                  ? const Icon(Icons.mode_edit_outline_outlined)
                  : const Icon(Icons.edit_off_outlined),
            ),
          ],
        ),

        const VerticalSpace(size: SpaceSize.xsmall),

        // List of goals grouped with tasks/ungrouped tasks
        if (goals.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goals.length,
            itemBuilder: (BuildContext context, int index) {
              final GoalModel goal = goals[index];

              final List<TaskModel> relatedTasks = allTasks
                  .where((TaskModel t) => t.goalId == goal.id)
                  .toList();

              final bool isGoalCompleted = state.completedGoalIds.contains(
                goal.id,
              );

              final bool isExpanded = state.expandedGoalId == goal.id;

              return Card(
                elevation: 0.5,
                child: Column(
                  children: <Widget>[
                    // Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: <Widget>[
                          // Checkbox
                          Checkbox(
                            value: isGoalCompleted,
                            onChanged: (_) =>
                                viewModel.toggleGoalCompletion(goal.id!),
                          ),

                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  goal.title,
                                  style: context.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    decoration: isGoalCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (relatedTasks.isNotEmpty)
                                  Text(
                                    '${relatedTasks.where((TaskModel t) => state.completedTaskIds.contains(t.id)).length}/${relatedTasks.length} Aufgaben erledigt',
                                    style: context.textTheme.bodyMedium!
                                        .copyWith(color: AppPalette.grey),
                                  ),
                              ],
                            ),
                          ),

                          // Delete button if no tasks
                          if (relatedTasks.isEmpty &&
                              state.isEditMode &&
                              goal.id != "0")
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: context.colorScheme.error,
                              ),
                              onPressed: () =>
                                  viewModel.deleteGoal(goalId: goal.id!),
                            ),

                          // Expand/Collapse arrow
                          if (state.isEditMode || relatedTasks.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () {
                                viewModel.toggleExpandedGoal(goal.id!);
                              },
                            ),
                        ],
                      ),
                    ),

                    // Expanded body with tasks
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Divider(
                              color: context.colorScheme.tertiary,
                              thickness: 4,
                              radius: BorderRadius.circular(10),
                            ),

                            ...relatedTasks.map(
                              (TaskModel task) => _TaskItem(
                                task: task,
                                isCompleted: state.completedTaskIds.contains(
                                  task.id,
                                ),
                                onToggle: () =>
                                    viewModel.toggleTaskCompletion(task.id!),
                                isEditMode: state.isEditMode,
                                onDelete: () =>
                                    viewModel.deleteTask(taskId: task.id!),
                              ),
                            ),
                            if (state.isEditMode)
                              CustomAddItemField(
                                controller: _taskGoalController,
                                hintText: "Neue Aufgabe für ${goal.title}...",
                                onSubmitted: () => _addTask(goal.id!),
                                onPressed: () => _addTask(goal.id!),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

        // Add new goal field at bottom (only if no goal is expanded)
        if (state.expandedGoalId == null && state.isEditMode)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 4.0,
            ),
            child: CustomAddItemField(
              controller: _taskGoalController,
              hintText: "Neues Ziel...",
              onSubmitted: () => _addGoal(),
              onPressed: () => _addGoal(),
            ),
          ),
      ],
    );
  }
}

// Task item
class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.task,
    required this.isCompleted,
    required this.onToggle,
    required this.onDelete,
    required this.isEditMode,
  });

  final TaskModel task;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 8.0,
      ),
      leading: Checkbox(value: isCompleted, onChanged: (_) => onToggle()),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: onToggle,
      trailing: isEditMode
          ? IconButton(
              onPressed: () {
                onDelete();
              },
              icon: Icon(Icons.delete, color: context.colorScheme.error),
            )
          : null,
    );
  }
}
