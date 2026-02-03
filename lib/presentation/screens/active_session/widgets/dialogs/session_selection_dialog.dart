import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/dialogs/show_custom_dialog.dart';

class SessionSelectionDialog {
  static Future<void> show({
    required BuildContext context,
    required List<GoalModel> newGoals,
    required List<TaskModel> newTasks,
    required List<GoalModel> deleteGoals,
    required List<TaskModel> deleteTasks,
    required List<GoalModel> existingGoalsWithNewTasks,
    required Future<void> Function(
      List<String> goalIds,
      List<String> taskIds,
      List<String> goalIdsToDelete,
      List<String> taskIdsToDelete,
    )
    onConfirm,
    required Future<void> Function() onDiscardAll,
  }) async {
    // Prepare new goals to show
    final newGoalIds = newGoals.map((g) => g.id).toSet();
    final tasksByGoal = _groupTasksByGoal(newTasks);

    final allDisplayedGoals = <GoalModel>[
      ...newGoals,
      ...existingGoalsWithNewTasks.where((g) => !newGoalIds.contains(g.id)),
    ];

    final ungroupedTasks = newTasks.where((t) => t.goalId == null).toList();

    // Initialize selections (all true by default)
    final goalSelection = <String, bool>{
      for (final goal in newGoals) goal.id!: true,
    };
    final taskSelection = <String, bool>{
      for (final task in newTasks) task.id!: true,
    };

    // Initialize selections for deleted items
    final deletedGoalSelection = <String, bool>{
      for (final goal in deleteGoals) goal.id!: true,
    };
    final deletedTaskSelection = <String, bool>{
      for (final task in deleteTasks) task.id!: true,
    };

    await showCustomDialog(
      context: context,
      centerLabels: true,
      title: 'Elemente auswählen',
      content: _SelectionDialogContent(
        allDisplayedGoals: allDisplayedGoals,
        newGoals: newGoals,
        tasksByGoal: tasksByGoal,
        ungroupedTasks: ungroupedTasks,
        goalSelection: goalSelection,
        taskSelection: taskSelection,
        deleteGoals: deleteGoals,
        deleteTasks: deleteTasks,
        deletedGoalSelection: deletedGoalSelection,
        deletedTaskSelection: deletedTaskSelection,
      ),
      confirmLabel: 'Bestätigen',
      cancelLabel: 'Alle verwerfen',
      onCancel: onDiscardAll,
      onConfirm: () async {
        final goalIdsToKeep = goalSelection.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

        final taskIdsToKeep = taskSelection.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

        // Any tasks which are not clicked to be selected
        final taskIdsToDiscard = taskSelection.entries
            .where((e) => !e.value)
            .map((e) => e.key)
            .toList();

        // Identify items to DELETE (items checked in the 'Deleted' section)
        final goalIdsToDelete = deletedGoalSelection.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

        final taskIdsToDeleteFromHistory = deletedTaskSelection.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList();

        final totalTaskIdsToDelete = {
          ...taskIdsToDiscard,
          ...taskIdsToDeleteFromHistory,
        }.toList();

        await onConfirm(
          goalIdsToKeep,
          taskIdsToKeep,
          goalIdsToDelete,
          totalTaskIdsToDelete,
        );
      },
    );
  }

  static Map<String, List<TaskModel>> _groupTasksByGoal(List<TaskModel> tasks) {
    final tasksByGoal = <String, List<TaskModel>>{};
    for (final task in tasks) {
      if (task.goalId != null) {
        tasksByGoal.putIfAbsent(task.goalId!, () => <TaskModel>[]).add(task);
      }
    }
    return tasksByGoal;
  }
}

class _SelectionDialogContent extends StatefulWidget {
  const _SelectionDialogContent({
    required this.allDisplayedGoals,
    required this.newGoals,
    required this.tasksByGoal,
    required this.ungroupedTasks,
    required this.goalSelection,
    required this.taskSelection,
    required this.deleteGoals,
    required this.deleteTasks,
    required this.deletedGoalSelection,
    required this.deletedTaskSelection,
  });

  final List<GoalModel> allDisplayedGoals;
  final List<GoalModel> newGoals;
  final Map<String, List<TaskModel>> tasksByGoal;
  final List<TaskModel> ungroupedTasks;
  final Map<String, bool> goalSelection;
  final Map<String, bool> taskSelection;

  final List<GoalModel> deleteGoals;
  final List<TaskModel> deleteTasks;
  final Map<String, bool> deletedGoalSelection;
  final Map<String, bool> deletedTaskSelection;

  @override
  State<_SelectionDialogContent> createState() =>
      _SelectionDialogContentState();
}

class _SelectionDialogContentState extends State<_SelectionDialogContent> {
  @override
  Widget build(BuildContext context) {
    final hasDeletedItems =
        widget.deleteGoals.isNotEmpty || widget.deleteTasks.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Neue Elemente',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
          const VerticalSpace(size: SpaceSize.xsmall),
          Text(
            '''Diese Elemente wurden in dieser Sitzung hinzugefügt. '''
            '''Markierte Elemente werden für zukünftige Sitzungen behalten.''',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppPalette.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const VerticalSpace(),

          // KEEP SELECTION SECTION
          // Goals with their tasks
          ...widget.allDisplayedGoals.map((goal) {
            return _GoalWithTasksItem(
              goal: goal,
              isNewGoal: widget.newGoals.any((g) => g.id == goal.id),
              tasks: widget.tasksByGoal[goal.id!] ?? [],
              goalSelected: widget.goalSelection[goal.id!] ?? false,
              taskSelection: widget.taskSelection,
              onGoalToggled: (value) => _onGoalToggled(goal, value),
              onTaskToggled: _onTaskToggled,
            );
          }),

          // Ungrouped tasks
          if (widget.ungroupedTasks.isNotEmpty) ...<Widget>[
            const VerticalSpace(),
            Text(
              'Sonstige Aufgaben',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppPalette.grey,
              ),
            ),
            ...widget.ungroupedTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(left: 32),
                child: _TaskCheckboxItem(
                  task: task,
                  isSelected: widget.taskSelection[task.id!] ?? false,
                  onToggled: (value) => _onTaskToggled(task.id!, value),
                ),
              );
            }),
          ],

          // DELETE SELECTION SECTION
          // Display deleted goals and or tasks:
          if (hasDeletedItems) ...<Widget>[
            const VerticalSpace(
              size: SpaceSize.xsmall,
            ),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
              radius: BorderRadius.circular(10),
            ),
            const VerticalSpace(size: SpaceSize.xsmall),

            Text(
              'Gelöschte Elemente',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppPalette.rose,
              ),
            ),
            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              'Diese Elemente wurden in dieser Sitzung gelöscht. '
              'Markierte Elemente werden dauerhaft gelöscht:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppPalette.grey,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Deleted goals
            if (widget.deleteGoals.isNotEmpty) ...<Widget>[
              ...widget.deleteGoals.map((goal) {
                return _GoalItem(
                  isDeletedMode: true,
                  goal: goal,
                  isSelected: widget.deletedGoalSelection[goal.id!] ?? false,
                  onToggled: (value) => _onDeletedGoalToggled(goal.id!, value),
                );
              }),
            ],

            // Deleted tasks
            if (widget.deleteTasks.isNotEmpty) ...<Widget>[
              const VerticalSpace(size: SpaceSize.small),
              Text(
                'Gelöschte Aufgaben',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppPalette.grey,
                ),
              ),
              ...widget.deleteTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: _TaskCheckboxItem(
                    isDeletedMode: true,
                    task: task,
                    isSelected: widget.deletedTaskSelection[task.id!] ?? false,
                    onToggled: (value) =>
                        _onDeletedTaskToggled(task.id!, value),
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  void _onGoalToggled(GoalModel goal, bool value) {
    setState(() {
      widget.goalSelection[goal.id!] = value;
      // Toggle all tasks under this goal
      final tasks = widget.tasksByGoal[goal.id!] ?? [];
      for (final task in tasks) {
        widget.taskSelection[task.id!] = value;
      }
    });
  }

  void _onTaskToggled(String taskId, bool value) {
    setState(() {
      widget.taskSelection[taskId] = value;
    });
  }

  void _onDeletedGoalToggled(String goalId, bool value) {
    setState(() {
      widget.deletedGoalSelection[goalId] = value;
    });
  }

  void _onDeletedTaskToggled(String taskId, bool value) {
    setState(() {
      widget.deletedTaskSelection[taskId] = value;
    });
  }
}

class _GoalWithTasksItem extends StatelessWidget {
  const _GoalWithTasksItem({
    required this.goal,
    required this.isNewGoal,
    required this.tasks,
    required this.goalSelected,
    required this.taskSelection,
    required this.onGoalToggled,
    required this.onTaskToggled,
  });

  final GoalModel goal;
  final bool isNewGoal;
  final List<TaskModel> tasks;
  final bool goalSelected;
  final Map<String, bool> taskSelection;
  final ValueChanged<bool> onGoalToggled;
  final void Function(String taskId, bool value) onTaskToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Goal row
        if (isNewGoal)
          _GoalItem(
            goal: goal,
            isSelected: goalSelected,
            onToggled: onGoalToggled,
          )
        else
          _ExistingGoalRow(goal: goal),

        // Tasks under this goal
        if (tasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: tasks.map((task) {
                return _TaskCheckboxItem(
                  task: task,
                  isSelected: taskSelection[task.id!] ?? false,
                  onToggled: (value) => onTaskToggled(task.id!, value),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _GoalItem extends StatelessWidget {
  const _GoalItem({
    required this.goal,
    required this.isSelected,
    required this.onToggled,
    this.isDeletedMode = false,
  });

  final GoalModel goal;
  final bool isSelected;
  final ValueChanged<bool> onToggled;
  final bool isDeletedMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.flag_outlined,
          size: 16,
          color: isDeletedMode ? AppPalette.rose : AppPalette.grey,
        ),
        const HorizontalSpace(),

        Expanded(
          child: GestureDetector(
            onTap: () => onToggled(!isSelected),
            child: Text(
              goal.title,
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: isDeletedMode ? AppPalette.rose : null,
                decoration: isDeletedMode ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),

        Checkbox(
          value: isSelected,
          activeColor: isDeletedMode ? AppPalette.rose : null,
          onChanged: (value) => onToggled(value ?? false),
        ),
      ],
    );
  }
}

class _ExistingGoalRow extends StatelessWidget {
  const _ExistingGoalRow({required this.goal});

  final GoalModel goal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.flag_outlined,
          size: 16,
          color: AppPalette.grey,
        ),
        const HorizontalSpace(),
        Expanded(
          child: Text(
            goal.title,
            style: context.textTheme.bodyMedium!.copyWith(
              color: AppPalette.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskCheckboxItem extends StatelessWidget {
  const _TaskCheckboxItem({
    required this.task,
    required this.isSelected,
    required this.onToggled,
    this.isDeletedMode = false,
  });

  final TaskModel task;
  final bool isSelected;
  final ValueChanged<bool> onToggled;
  final bool isDeletedMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.check_box_outline_blank_rounded,
          size: 16,
          color: isDeletedMode ? AppPalette.rose : AppPalette.grey,
        ),
        const HorizontalSpace(),
        Expanded(
          child: GestureDetector(
            onTap: () => onToggled(!isSelected),
            child: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDeletedMode ? AppPalette.rose : null,
                decoration: isDeletedMode ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
        Checkbox(
          value: isSelected,
          activeColor: isDeletedMode ? AppPalette.rose : null,
          onChanged: (value) => onToggled(value ?? false),
        ),
      ],
    );
  }
}
