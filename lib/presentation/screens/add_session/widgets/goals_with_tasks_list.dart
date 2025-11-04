import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/input_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class GoalWithTasksCard extends ConsumerWidget {
  const GoalWithTasksCard({
    super.key,
    required this.goal,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onAddTask,
    required this.taskController,
  });

  final GoalModel goal;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddTask;
  final TextEditingController taskController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);
    final List<TaskModel> goalTasks = state.tasksForGoal(goal.id!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomItemTile(text: goal.title, isLargeGoal: true),

          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(8.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onToggleExpand,
            child: Text(
              isExpanded ? "Aufgabe ausblenden" : "Aufgabe hinzufügen?",
            ),
          ),

          const VerticalSpace(size: SpaceSize.small),

          if (isExpanded)
            InputList<TaskModel>(
              controller: taskController,
              onEnter: onAddTask,
              isBigGoal: false,
              items: const <TaskModel>[],
              hideHeadline: true,
            ),

          if (goalTasks.isNotEmpty) ..._buildTasksList(goalTasks, state, ref),
        ],
      ),
    );
  }

  List<Widget> _buildTasksList(
    List<TaskModel> goalTasks,
    AddSessionState state,
    WidgetRef ref,
  ) {
    return goalTasks.map((TaskModel task) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.check_box_outline_blank_rounded, size: 25),
            const SizedBox(width: 8),
            Expanded(child: Text(task.title, overflow: TextOverflow.ellipsis)),
            IconButton(
              icon: const Icon(Icons.delete, size: 25),
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
                ref
                    .read(addSessionViewModelProvider.notifier)
                    .removeTask(state.tasks.indexOf(task));
              },
            ),
          ],
        ),
      );
    }).toList();
  }
}
