import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class GoalsListWidget extends ConsumerStatefulWidget {
  const GoalsListWidget({required this.instanceId, super.key});

  final int instanceId;

  @override
  ConsumerState<GoalsListWidget> createState() => _GoalsListWidgetState();
}

class _GoalsListWidgetState extends ConsumerState<GoalsListWidget> {
  final TextEditingController _taskGoalController = TextEditingController();
  static const String ungroupedGoalId = '__ungrouped__';

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
          goalId: goalId == ungroupedGoalId
              ? null // for "Sonstige Aufgaben"
              : goalId,
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
    final state = ref.watch(
      activeSessionViewModelProvider(widget.instanceId),
    );
    final viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    var goals = List<GoalModel>.from(state.goals);
    final allTasks = List<TaskModel>.from(state.tasks);

    // Add a temporary goal;
    // with special goal id to add ungrouped tasks
    const ungroupedGoal = GoalModel(
      id: ungroupedGoalId,
      title: 'Sonstige Aufgaben',
      keptForFutureSessions: false,
    );

    goals = <GoalModel>[...goals, ungroupedGoal];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Ziele & Aufgaben',
              style: context.textTheme.headlineSmall!.copyWith(
                color: context.colorScheme.brightness == Brightness.dark
                    ? context.colorScheme.surface
                    : context.colorScheme.onSurface,
              ),
            ),
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
              final goal = goals[index];

              final relatedTasks = allTasks
                  .where(
                    (TaskModel t) => goal.id == ungroupedGoalId
                        ? t.goalId ==
                              null // Match orphaned tasks
                        : t.goalId == goal.id, // Match normal tasks
                  )
                  .toList();

              final isGoalCompleted = state.completedGoalIds.contains(
                goal.id,
              );

              final isExpanded = state.expandedGoalId == goal.id;

              return Card(
                elevation: 0,
                child: Column(
                  children: <Widget>[
                    // Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: <Widget>[
                          // Checkbox; invisible for tasks
                          // under 'Sonstige Aufgaben'
                          Opacity(
                            opacity: goal.id != ungroupedGoalId ? 1.0 : 0.0,
                            child: Checkbox(
                              value: isGoalCompleted,
                              onChanged: goal.id != ungroupedGoalId
                                  ? (_) =>
                                        viewModel.toggleGoalCompletion(goal.id!)
                                  : null,
                            ),
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
                                if (relatedTasks.isEmpty)
                                  Text(
                                    'Keine Aufgaben',
                                    style: context.textTheme.bodyMedium!
                                        .copyWith(color: AppPalette.grey),
                                  ),
                              ],
                            ),
                          ),

                          // Delete button if no tasks
                          if (relatedTasks.isEmpty &&
                              state.isEditMode &&
                              goal.id != ungroupedGoalId)
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: context.colorScheme.error,
                              ),
                              onPressed: () =>
                                  viewModel.removeGoalById(goalId: goal.id!),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: <Widget>[
                            Divider(
                              color: context.colorScheme.tertiary,
                              thickness: 4,
                              radius: BorderRadius.circular(10),
                            ),

                            const VerticalSpace(size: SpaceSize.xsmall),

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
                                    viewModel.removeTaskById(taskId: task.id!),
                              ),
                            ),
                            if (state.isEditMode)
                              CustomAddItemField(
                                controller: _taskGoalController,
                                hintText: 'Neue Aufgabe für ${goal.title}...',
                                onSubmitted: () => _addTask(goal.id),
                                onPressed: () => _addTask(goal.id),
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
              vertical: 12,
              horizontal: 4,
            ),
            child: CustomAddItemField(
              controller: _taskGoalController,
              hintText: 'Neues Ziel...',
              onSubmitted: _addGoal,
              onPressed: _addGoal,
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
      contentPadding: const EdgeInsets.only(left: 16),
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
              onPressed: onDelete,
              icon: Icon(Icons.delete, color: context.colorScheme.error),
            )
          : null,
    );
  }
}
