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
  final TextEditingController _taskGoalController = TextEditingController();
  final ScrollController _goalsScrollController = ScrollController();
  String? _expandedGoalId;

  @override
  void dispose() {
    _taskGoalController.dispose();
    _goalsScrollController.dispose();
    super.dispose();
  }

  Future<void> _addTask(String? goalId) async {
    if (_taskGoalController.text.trim().isEmpty) return;

    await ref
        .read(activeSessionViewModelProvider(widget.instanceId).notifier)
        .addTask(
          _taskGoalController.text.trim(),
          goalId: goalId, // if task should belong to some goal; else null
        );

    _taskGoalController.clear();

    // Scroll down when general task
    if (goalId == null) {
      await _goalsScrollController.animateTo(
        _goalsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _addGoal(String? goalId) async {
    if (_taskGoalController.text.trim().isEmpty) return;

    await ref
        .read(activeSessionViewModelProvider(widget.instanceId).notifier)
        .addGoal(_taskGoalController.text.trim());

    _taskGoalController.clear();

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

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Ziele & Aufgaben',
                  style: context.textTheme.headlineMedium,
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: state.isEditMode
                      ? context.colorScheme.onTertiary
                      : context.colorScheme.primary,
                  child: IconButton(
                    onPressed: viewModel.toggleEditMode,
                    icon: Icon(
                      state.isEditMode
                          ? Icons.edit_off_outlined
                          : Icons.edit_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const VerticalSpace(size: SpaceSize.small),

            Expanded(
              child: SingleChildScrollView(
                controller: _goalsScrollController,
                child: ExpansionPanelList.radio(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _expandedGoalId = isExpanded ? null : goals[index].id;
                    });
                  },
                  elevation: 0,
                  materialGapSize: 4.0,
                  dividerColor: context.colorScheme.tertiary,
                  children: goals.map<ExpansionPanelRadio>((GoalModel goal) {
                    final List<TaskModel> relatedTasks = state.tasksForGoal(
                      goal.id!,
                    );
                    final bool isGoalCompleted = state.completedGoalIds
                        .contains(goal.id);

                    return ExpansionPanelRadio(
                      canTapOnHeader: true,
                      value: goal.id!, // unique ID per goal
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0.0,
                          ),
                          leading: Checkbox(
                            value: isGoalCompleted,
                            onChanged: (_) =>
                                viewModel.toggleGoalCompletion(goal.id!),
                          ),
                          title: Text(
                            goal.title,
                            style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isGoalCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: relatedTasks.isNotEmpty
                              ? Text(
                                  '${relatedTasks.where((TaskModel t) => state.completedTaskIds.contains(t.id)).length}/${relatedTasks.length} Aufgaben erledigt',
                                  style: context.textTheme.bodyMedium,
                                )
                              : null,
                        );
                      },

                      body: Column(
                        children: <Widget>[
                          // Tasks list
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
                    );
                  }).toList(),
                ),
              ),
            ),

            // Add new goal field at bottom, if no current goal is expanded
            if (_expandedGoalId != null && state.isEditMode) ...<Widget>[
              const VerticalSpace(size: SpaceSize.small),
              CustomAddItemField(
                controller: _taskGoalController,
                hintText: "Neues Ziel...",
                onSubmitted: () => _addGoal(null),
                onPressed: () => _addGoal(null),
              ),
            ],
          ],
        ),
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
      contentPadding: const EdgeInsets.only(left: 8.0),
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
              icon: const Icon(Icons.delete_outline_rounded),
            )
          : null,
    );
  }
}
