import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/show_custom_dialog.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

/// Animated button to leave the session
/// Requires double tap to avoid accidentally leaving the session
/// and kept minimal to avoid users directly clicking it
class ExitButton extends ConsumerStatefulWidget {
  const ExitButton({super.key, required this.instanceId});

  final int instanceId;

  @override
  ConsumerState<ExitButton> createState() => _ExitButtonState();
}

class _ExitButtonState extends ConsumerState<ExitButton> {
  bool _tappedOnce = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setTappedOnce() {
    setState(() => _tappedOnce = true);

    _timer?.cancel();

    // If not clicked again after 5 seconds, close the button
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _tappedOnce = false);
      }
    });
  }

  Future<void> _stopSession() async {
    // Do not close the button when dialog is open
    _timer?.cancel();

    final ActiveSessionState state = ref.read(
      activeSessionViewModelProvider(widget.instanceId),
    );
    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    // Stop the session
    if (state.timerStatus != TimerStatus.initial) {
      viewModel.pauseTimer();

      // Filter to only show items that are NEW to this session
      final List<GoalModel> newGoals = state.newlyAddedGoals;
      final List<TaskModel> newTasks = state.newlyAddedTasks;

      // Group tasks by goalId
      final Map<String, List<TaskModel>> tasksByGoal =
          <String, List<TaskModel>>{};
      for (final TaskModel task in newTasks) {
        if (task.goalId != null) {
          tasksByGoal.putIfAbsent(task.goalId!, () => <TaskModel>[]).add(task);
        }
      }

      // Get all existing goals that have new tasks
      final List<GoalModel> existingGoalsWithNewTasks = state
          .getExistingGoalsWithNewTasks();

      // Combine: new goals + existing goals with new tasks
      final List<GoalModel> allDisplayedGoals = <GoalModel>[
        ...newGoals,
        ...existingGoalsWithNewTasks,
      ];

      // Separate ungrouped tasks
      final List<TaskModel> ungroupedTasks = newTasks
          .where((TaskModel t) => t.goalId == null)
          .toList();

      // Track selection - only for items to decide
      final Map<String, bool> goalSelection = <String, bool>{
        for (GoalModel g in newGoals) g.id!: false,
      };
      final Map<String, bool> taskSelection = <String, bool>{
        for (TaskModel t in newTasks) t.id!: false,
      };

      await showCustomDialog(
        context: context,
        title: "Lerneinheit beenden",
        content: StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Willst du diese Lerneinheit wirklich beenden?",
                    style: context.textTheme.bodyMedium,
                  ),
                  if (state.session!.isRepeating &&
                      (newGoals.isNotEmpty || newTasks.isNotEmpty)) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.medium),
                    Text(
                      "Neue Elemente für diese Einheit:",
                      style: context.textTheme.labelMedium,
                    ),
                    const VerticalSpace(size: SpaceSize.xsmall),
                    Text(
                      "Wähle die Elemente aus, die du für zukünftige Sitzungen behalten möchtest:",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppPalette.grey,
                      ),
                    ),

                    const VerticalSpace(size: SpaceSize.small),

                    // Goals with their tasks
                    ...allDisplayedGoals.map((GoalModel goal) {
                      final List<TaskModel> goalTasks =
                          tasksByGoal[goal.id!] ?? <TaskModel>[];
                      final bool isNewGoal = !goal.keptForFutureSessions;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Goal row
                          Row(
                            children: <Widget>[
                              // Show checkbox only for NEW goals
                              if (isNewGoal) ...<Widget>[
                                Icon(
                                  Icons.flag_outlined,
                                  size: 16,
                                  color: AppPalette.grey,
                                ),
                                Checkbox(
                                  value: goalSelection[goal.id!] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      goalSelection[goal.id!] = value ?? false;
                                      // Toggle all tasks under this goal
                                      for (final TaskModel task in goalTasks) {
                                        taskSelection[task.id!] =
                                            value ?? false;
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        final bool newValue =
                                            !(goalSelection[goal.id!] ?? false);
                                        goalSelection[goal.id!] = newValue;
                                        for (final TaskModel task
                                            in goalTasks) {
                                          taskSelection[task.id!] = newValue;
                                        }
                                      });
                                    },
                                    child: Text(
                                      goal.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              // Show plain text for EXISTING goals (context only)
                              if (!isNewGoal)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 12.0,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.flag_outlined,
                                          size: 16,
                                          color: AppPalette.grey,
                                        ),
                                        const HorizontalSpace(
                                          size: SpaceSize.small,
                                        ),
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
                                  ),
                                ),
                            ],
                          ),

                          // Tasks under this goal
                          if (goalTasks.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: Column(
                                children: goalTasks.map((TaskModel task) {
                                  return Row(
                                    children: <Widget>[
                                      Checkbox(
                                        value: taskSelection[task.id!] ?? false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            taskSelection[task.id!] =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              taskSelection[task.id!] =
                                                  !(taskSelection[task.id!] ??
                                                      false);
                                            });
                                          },
                                          child: Text(task.title),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    }),

                    // Ungrouped tasks
                    if (ungroupedTasks.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        "Sonstige Aufgaben:",
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppPalette.grey,
                        ),
                      ),
                      ...ungroupedTasks.map((TaskModel task) {
                        return Row(
                          children: <Widget>[
                            Checkbox(
                              value: taskSelection[task.id!] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  taskSelection[task.id!] = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    taskSelection[task.id!] =
                                        !(taskSelection[task.id!] ?? false);
                                  });
                                },
                                child: Text(task.title),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],

                    const VerticalSpace(size: SpaceSize.medium),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Nicht markierte Elemente werden als abgeschlossen markiert",
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppPalette.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        confirmLabel: "Bestätigen",
        cancelLabel: "Abbrechen",
        onCancel: () => viewModel.startTimer(),
        onConfirm: () async {
          final List<String> goalIdsToKeep = goalSelection.entries
              .where((MapEntry<String, bool> e) => e.value)
              .map((MapEntry<String, bool> e) => e.key)
              .toList();
          final List<String> taskIdsToKeep = taskSelection.entries
              .where((MapEntry<String, bool> e) => e.value)
              .map((MapEntry<String, bool> e) => e.key)
              .toList();

          for (final String taskId in taskIdsToKeep) {
            final TaskModel task = state.newlyAddedTasks.firstWhere(
              (TaskModel t) => t.id == taskId,
            );
            // If task has a goalId and that goal is NOT being kept,
            // set its goalId to null and "orphan" it
            if (task.goalId != null && !goalIdsToKeep.contains(task.goalId)) {
              await viewModel.orphanTask(task);
            }
          }

          final SessionInstanceModel updatedInstance = await viewModel
              .completeSession(
                goalIdsToKeep: goalIdsToKeep,
                taskIdsToKeep: taskIdsToKeep,
              );

          if (!mounted) return;
          await Navigator.pushReplacementNamed(
            context,
            AppRoutes.reflection,
            arguments: updatedInstance,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // First tap extend
        if (!_tappedOnce) {
          _setTappedOnce();
        } else {
          // Second tap; show dialog
          await _stopSession();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _tappedOnce ? context.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.exit_to_app,
              color: _tappedOnce ? Colors.white : context.colorScheme.primary,
              size: 30,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _tappedOnce
                  ? const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Lerneinheit beenden?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
