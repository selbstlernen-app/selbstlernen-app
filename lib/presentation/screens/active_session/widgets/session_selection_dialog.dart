import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/show_custom_dialog.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/models.dart';

class SessionSelectionDialog {
  static Future<void> show({
    required BuildContext context,
    required List<GoalModel> newGoals,
    required List<TaskModel> newTasks,
    required List<GoalModel> existingGoalsWithNewTasks,
    required Future<void> Function(
      List<String> goalIds,
      List<String> taskIds,
    )
    onConfirm,
    required Future<void> Function() onDiscardAll,
  }) async {
    // Prepare data
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

    await showCustomDialog(
      context: context,
      title: 'Elemente auswählen',
      content: _SelectionDialogContent(
        allDisplayedGoals: allDisplayedGoals,
        newGoals: newGoals,
        tasksByGoal: tasksByGoal,
        ungroupedTasks: ungroupedTasks,
        goalSelection: goalSelection,
        taskSelection: taskSelection,
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

        await onConfirm(goalIdsToKeep, taskIdsToKeep);
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
  });

  final List<GoalModel> allDisplayedGoals;
  final List<GoalModel> newGoals;
  final Map<String, List<TaskModel>> tasksByGoal;
  final List<TaskModel> ungroupedTasks;
  final Map<String, bool> goalSelection;
  final Map<String, bool> taskSelection;

  @override
  State<_SelectionDialogContent> createState() =>
      _SelectionDialogContentState();
}

class _SelectionDialogContentState extends State<_SelectionDialogContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Wähle die Elemente aus, die du für zukünftige Sitzungen behalten möchtest:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const VerticalSpace(),

          // Goals with their tasks
          ...widget.allDisplayedGoals.map((goal) {
            return _GoalWithTasksItem(
              goal: goal,
              isNewGoal: widget.newGoals.any((g) => g.id == goal.id),
              tasks: widget.tasksByGoal[goal.id!] ?? [],
              goalSelected: widget.goalSelection[goal.id!] ?? false,
              taskSelection: widget.taskSelection,
              onGoalToggled: (value) => _onGoalToggled(goal, value),
              onTaskToggled: (taskId, value) => _onTaskToggled(taskId, value),
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
              return _TaskCheckboxItem(
                task: task,
                isSelected: widget.taskSelection[task.id!] ?? false,
                onToggled: (value) => _onTaskToggled(task.id!, value),
              );
            }),
          ],

          const VerticalSpace(),
          _InfoContainer(
            text: 'Markierte Elemente werden für zukünftige Sitzungen behalten',
          ),
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
          _NewGoalRow(
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

class _NewGoalRow extends StatelessWidget {
  const _NewGoalRow({
    required this.goal,
    required this.isSelected,
    required this.onToggled,
  });

  final GoalModel goal;
  final bool isSelected;
  final ValueChanged<bool> onToggled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.flag_outlined,
          size: 16,
          color: AppPalette.grey,
        ),
        Checkbox(
          value: isSelected,
          onChanged: (value) => onToggled(value ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onToggled(!isSelected),
            child: Text(
              goal.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.flag_outlined,
            size: 16,
            color: AppPalette.grey,
          ),
          const HorizontalSpace(size: SpaceSize.small),
          Expanded(
            child: Text(
              goal.title,
              style: TextStyle(
                color: AppPalette.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCheckboxItem extends StatelessWidget {
  const _TaskCheckboxItem({
    required this.task,
    required this.isSelected,
    required this.onToggled,
  });

  final TaskModel task;
  final bool isSelected;
  final ValueChanged<bool> onToggled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: isSelected,
          onChanged: (value) => onToggled(value ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onToggled(!isSelected),
            child: Text(task.title),
          ),
        ),
      ],
    );
  }
}

class _InfoContainer extends StatelessWidget {
  const _InfoContainer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: AppPalette.grey,
        ),
      ),
    );
  }
}
