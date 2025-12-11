import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/dialogs/session_selection_dialog.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/dialogs/stop_session_dialog.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

/// Animated button to leave the session
/// Requires double tap to avoid accidentally leaving the session
/// and kept minimal to avoid users directly clicking it
class ExitButton extends ConsumerStatefulWidget {
  const ExitButton({required this.instanceId, super.key});

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

    final state = ref.read(
      activeSessionViewModelProvider(widget.instanceId),
    );
    final viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    // Stop the session
    if (state.timerStatus != TimerStatus.initial) {
      await viewModel.pauseTimer();

      if (!mounted) return;

      final newGoals = state.newlyAddedGoals;
      final newTasks = state.newlyAddedTasks;
      final totalEdits = newGoals.length + newTasks.length;

      await StopSessionDialog.show(
        context: context,
        totalEdits: totalEdits,
        isRepeating: state.session!.isRepeating,
        onStartTimer: viewModel.startTimer,
        onDiscardAll: () => _completeSessionAndNavigate(
          viewModel: viewModel,
          goalIdsToKeep: [],
          taskIdsToKeep: [],
          goalIdsToDelete: [],
          taskIdsToDelete: [],
        ),
        onShowDetailedSelection: () => _showDetailedSelection(
          state: state,
          viewModel: viewModel,
          newGoals: newGoals,
          newTasks: newTasks,
        ),
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
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Lerneinheit beenden?',
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

  Future<void> _showDetailedSelection({
    required ActiveSessionState state,
    required ActiveSessionViewModel viewModel,
    required List<GoalModel> newGoals,
    required List<TaskModel> newTasks,
  }) async {
    final newGoalIds = newGoals.map((g) => g.id).toSet();
    final existingGoalsWithNewTasks = state
        .getExistingGoalsWithNewTasks()
        .where((g) => !newGoalIds.contains(g.id))
        .toList();

    final deleteGoals = state.deleteGoals;
    final deleteTasks = state.deleteTasks;

    await SessionSelectionDialog.show(
      context: context,
      newGoals: newGoals,
      newTasks: newTasks,
      deleteGoals: deleteGoals,
      deleteTasks: deleteTasks,
      existingGoalsWithNewTasks: existingGoalsWithNewTasks,
      onConfirm: (goalIds, taskIds, deletedGoalIds, deletedTaskIds) =>
          _handleSelectionConfirm(
            state: state,
            viewModel: viewModel,
            goalIdsToKeep: goalIds,
            taskIdsToKeep: taskIds,
            goalIdsToDelete: deletedGoalIds,
            taskIdsToDelete: deletedTaskIds,
          ),
      onDiscardAll: () => _completeSessionAndNavigate(
        viewModel: viewModel,
        goalIdsToKeep: [],
        taskIdsToKeep: [],
        goalIdsToDelete: [],
        taskIdsToDelete: [],
      ),
    );
  }

  Future<void> _handleSelectionConfirm({
    required ActiveSessionState state,
    required ActiveSessionViewModel viewModel,
    required List<String> goalIdsToKeep,
    required List<String> taskIdsToKeep,
    required List<String> goalIdsToDelete,
    required List<String> taskIdsToDelete,
  }) async {
    // Close selection dialog before navigating
    if (mounted) Navigator.of(context).pop();

    // Orphan tasks whose goals are being removed
    final goalIdsBeingRemoved = state.newlyAddedGoals
        .where((g) => !goalIdsToKeep.contains(g.id))
        .map((g) => g.id!)
        .toSet();

    for (final taskId in taskIdsToKeep) {
      final task = state.newlyAddedTasks.firstWhere((t) => t.id == taskId);
      if (task.goalId != null && goalIdsBeingRemoved.contains(task.goalId)) {
        await viewModel.orphanTask(task);
      }
    }

    await _completeSessionAndNavigate(
      viewModel: viewModel,
      goalIdsToKeep: goalIdsToKeep,
      taskIdsToKeep: taskIdsToKeep,
      goalIdsToDelete: goalIdsToDelete,
      taskIdsToDelete: taskIdsToDelete,
    );
  }

  Future<void> _completeSessionAndNavigate({
    required ActiveSessionViewModel viewModel,
    required List<String> goalIdsToKeep,
    required List<String> taskIdsToKeep,
    required List<String> goalIdsToDelete,
    required List<String> taskIdsToDelete,
  }) async {
    final updatedInstance = await viewModel.completeSession(
      goalIdsToKeep: goalIdsToKeep,
      taskIdsToKeep: taskIdsToKeep,
      goalIdsToDelete: goalIdsToDelete,
      taskIdsToDelete: taskIdsToDelete,
    );

    if (!mounted) return;

    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.reflection,
      arguments: updatedInstance,
    );
  }
}
