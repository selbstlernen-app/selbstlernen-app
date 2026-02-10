import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
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
    var goals = ref.watch(
      activeSessionViewModelProvider(widget.instanceId).select((s) => s.goals),
    );
    final tasks = ref.watch(
      activeSessionViewModelProvider(widget.instanceId).select((s) => s.tasks),
    );
    final isEditMode = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.isEditMode),
    );
    final expandedGoalId = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.expandedGoalId),
    );
    final completedGoalIds = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.completedGoalIds),
    );
    final completedTaskIds = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.completedTaskIds),
    );

    // Add a temporary goal;
    // with special goal id to add ungrouped tasks
    const ungroupedGoal = GoalModel(
      id: ungroupedGoalId,
      title: 'Sonstige Aufgaben',
      keptForFutureSessions: false,
    );

    final viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    goals = <GoalModel>[...goals, ungroupedGoal];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _GoalsHeader(instanceId: widget.instanceId),

        // Header
        const VerticalSpace(size: SpaceSize.xsmall),

        // List of goals grouped with tasks/ungrouped tasks
        if (goals.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goals.length,
            itemBuilder: (BuildContext context, int index) {
              final goal = goals[index];
              final isExpanded = expandedGoalId == goal.id;
              final isGoalCompleted = completedGoalIds.contains(goal.id);

              // Filter tasks locally
              final relatedTasks = tasks
                  .where(
                    (t) => goal.id == ungroupedGoalId
                        ? t.goalId == null
                        : t.goalId == goal.id,
                  )
                  .toList();

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
                                    '${relatedTasks.where((TaskModel t) => completedTaskIds.contains(t.id)).length}/${relatedTasks.length} Aufgaben erledigt',
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
                              isEditMode &&
                              goal.id != ungroupedGoalId)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever_rounded,
                              ),
                              onPressed: () =>
                                  viewModel.removeGoalById(goalId: goal.id!),
                            ),

                          // Expand/Collapse arrow
                          if (isEditMode || relatedTasks.isNotEmpty)
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
                                isCompleted: completedTaskIds.contains(
                                  task.id,
                                ),
                                onToggle: () =>
                                    viewModel.toggleTaskCompletion(task.id!),
                                isEditMode: isEditMode,
                                onDelete: () =>
                                    viewModel.removeTaskById(taskId: task.id!),
                              ),
                            ),
                            if (isEditMode)
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
        if (expandedGoalId == null && isEditMode)
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

class _GoalsHeader extends ConsumerWidget {
  const _GoalsHeader({required this.instanceId});
  final int instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(
      activeSessionViewModelProvider(instanceId).select(
        (s) => s.isEditMode,
      ),
    );

    return Row(
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
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: CustomIconButton(
            radius: 40,
            icon: Icon(
              isEditMode ? Icons.edit_off_outlined : Icons.edit,
            ),
            label: isEditMode ? 'Fertig' : 'Bearbeiten',
            isActive: true,
            onPressed: () => ref
                .read(activeSessionViewModelProvider(instanceId).notifier)
                .toggleEditMode(),
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
              icon: const Icon(
                Icons.delete_forever_rounded,
              ),
            )
          : null,
    );
  }
}
