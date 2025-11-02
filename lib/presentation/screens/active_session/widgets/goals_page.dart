import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key, required this.fullSessionModel});

  final FullSessionModel fullSessionModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActiveSessionState state = ref.watch(
      activeSessionViewModelProvider(fullSessionModel),
    );
    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(fullSessionModel).notifier,
    );

    // Goals and (ungrouped) tasks
    final List<GoalModel> goals = state.fullSession.goals;
    final List<TaskModel> ungroupedTasks = state.ungroupedTasks;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Ziele & Aufgaben', style: context.textTheme.headlineMedium),

            const VerticalSpace(size: SpaceSize.medium),

            Expanded(
              child: ListView(
                children: <Widget>[
                  // Map goals and their tasks (if any are linked to it)
                  ...goals.map((GoalModel goal) {
                    final List<TaskModel> relatedTasks = state.tasksForGoal(
                      goal.id!,
                    );
                    return _GoalWithTasksItem(
                      goal: goal,
                      tasks: relatedTasks,
                      completedGoalIds: state.completedGoalIds,
                      completedTaskIds: state.completedTaskIds,
                      onGoalToggle: (String goalId) =>
                          viewModel.toggleGoalCompletion(goalId),
                      onTaskToggle: (String taskId) =>
                          viewModel.toggleTaskCompletion(taskId),
                    );
                  }),

                  // Divider if there are both grouped and ungrouped tasks
                  if (goals.isNotEmpty &&
                      ungroupedTasks.isNotEmpty) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.xsmall),
                    Divider(
                      color: context.colorScheme.tertiary,
                      thickness: 4,
                      radius: const BorderRadius.all(Radius.circular(10)),
                    ),
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
  });

  final GoalModel goal;
  final List<TaskModel> tasks;
  final Set<String> completedGoalIds;
  final Set<String> completedTaskIds;
  final Function(String) onGoalToggle;
  final Function(String) onTaskToggle;

  @override
  Widget build(BuildContext context) {
    final bool isGoalCompleted = completedGoalIds.contains(goal.id);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 4.0),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: Checkbox(
          value: isGoalCompleted,
          onChanged: (_) => onGoalToggle(goal.id!),
        ),
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
