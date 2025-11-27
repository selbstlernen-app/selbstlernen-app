import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/input_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class GoalWithTasksCard extends ConsumerWidget {
  final GoalModel goal;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddTask;
  final TextEditingController taskController;

  const GoalWithTasksCard({
    super.key,
    required this.goal,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onAddTask,
    required this.taskController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);
    final List<TaskModel> goalTasks = state.tasksForGoal(goal.id!);

    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Goal header
            InkWell(
              onTap: onToggleExpand,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: <Widget>[
                    // Goal icon
                    Icon(
                      Icons.flag_outlined,
                      color: context.colorScheme.primary,
                      size: 24,
                    ),

                    const HorizontalSpace(size: SpaceSize.medium),

                    // Goal title + task count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            goal.title,
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (goalTasks.isNotEmpty)
                            Text(
                              '${goalTasks.length} ${goalTasks.length == 1 ? "Aufgabe" : "Aufgaben"}',
                              style: context.textTheme.bodyMedium!.copyWith(
                                color: AppPalette.grey,
                                fontSize: 13,
                              ),
                            ),
                          if (goalTasks.isEmpty)
                            Text(
                              'Noch keine Aufgaben',
                              style: context.textTheme.bodyMedium!.copyWith(
                                color: AppPalette.grey,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Expand/Collapse arrow
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppPalette.grey,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const VerticalSpace(size: SpaceSize.xsmall),
                    Divider(
                      color: context.colorScheme.tertiary,
                      thickness: 4,
                      radius: BorderRadius.circular(10),
                    ),
                    const VerticalSpace(size: SpaceSize.xsmall),

                    // Existing tasks
                    if (goalTasks.isNotEmpty) ...<Widget>[
                      ...goalTasks.map((TaskModel task) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 32.0),
                          child: Row(
                            children: <Widget>[
                              // Task icon
                              Icon(
                                Icons.check_box_outline_blank_rounded,
                                size: 20,
                                color: AppPalette.grey,
                              ),

                              const HorizontalSpace(size: SpaceSize.small),

                              // Task title
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: context.textTheme.bodyMedium,
                                ),
                              ),

                              // Delete button
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: context.colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final AddSessionViewModel notifier = ref.read(
                                    addSessionViewModelProvider.notifier,
                                  );
                                  final AddSessionState state = ref.read(
                                    addSessionViewModelProvider,
                                  );
                                  if (state.isEditingMode && task.id != null) {
                                    notifier.markTaskIdForDeletion(task.id!);
                                  }
                                  notifier.removeTask(
                                    state.tasks.indexOf(task),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    const VerticalSpace(size: SpaceSize.medium),

                    // Add task input
                    InputList<TaskModel>(
                      controller: taskController,
                      onEnter: onAddTask,
                      isBigGoal: false,
                      items: const <TaskModel>[],
                      hideHeadline: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
