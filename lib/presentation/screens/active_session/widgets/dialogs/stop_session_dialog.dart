import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/dialogs/session_selection_dialog.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/dialogs/show_custom_dialog.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class StopSessionDialog {
  StopSessionDialog({
    required this.context,
    required this.ref,
  });

  final BuildContext context;
  final WidgetRef ref;

  Future<void> showStopSessionFlow({
    required ActiveSessionState state,
    required ActiveSessionViewModel viewModel,
  }) async {
    final newGoals = state.newlyAddedGoals;
    final newTasks = state.newlyAddedTasks;

    final deleteGoals = state.deleteGoals;
    final deleteTasks = state.deleteTasks;
    final totalEdits =
        newGoals.length +
        newTasks.length +
        deleteGoals.length +
        deleteTasks.length;

    if (!state.session!.isRepeating || totalEdits == 0) {
      // No edits or not repeating -> go directly to reflection
      await _completeSessionAndNavigate(
        viewModel: viewModel,
        goalIdsToKeep: [],
        taskIdsToKeep: [],
        goalIdsToDelete: newGoals.map((g) => g.id!).toList(),
        taskIdsToDelete: newTasks.map((t) => t.id!).toList(),
      );
      return;
    }

    await showCustomDialog(
      centerLabels: true,
      context: context,
      title: 'Lerneinheit beenden',
      content: Text(
        '''Du hast $totalEdits ${totalEdits == 1 ? 'Ziel/Aufgabe' : 'Ziele und Aufgaben '}'''
        '''in dieser Lerneinheit bearbeitet, möchtest du die Bearbeitungen übernehmen?''',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      confirmLabel: 'Ja',
      cancelLabel: 'Nein',
      onCancel: () => _completeSessionAndNavigate(
        viewModel: viewModel,
        goalIdsToKeep: [],
        taskIdsToKeep: [],
        goalIdsToDelete: newGoals.map((g) => g.id!).toList(),
        taskIdsToDelete: newTasks.map((t) => t.id!).toList(),
      ),
      onConfirm: () => _showDetailedSelection(
        state: state,
        viewModel: viewModel,
        newGoals: newGoals,
        newTasks: newTasks,
      ),
    );
  }

  Future<void> _showDetailedSelection({
    required ActiveSessionState state,
    required ActiveSessionViewModel viewModel,
    required List<GoalModel> newGoals,
    required List<TaskModel> newTasks,
  }) async {
    final newGoalIds = newGoals.map((g) => g.id).whereType<String>().toSet();

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
      onDiscardAll:
          ({
            required List<String> goalIdsToDelete,
            required List<String> taskIdsToDelete,
          }) => _completeSessionAndNavigate(
            viewModel: viewModel,
            goalIdsToKeep: [],
            taskIdsToKeep: [],
            goalIdsToDelete: goalIdsToDelete,
            taskIdsToDelete: taskIdsToDelete,
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
    if (context.mounted) Navigator.of(context).pop();

    // Orphan tasks whose goals are being removed
    final goalIdsBeingRemoved = state.newlyAddedGoals
        .where((g) => !goalIdsToKeep.contains(g.id))
        .map((g) => g.id!)
        .toSet();

    // Batch orphan operations
    final orphanFutures = <Future<void>>[];

    for (final taskId in taskIdsToKeep) {
      final task = state.newlyAddedTasks.firstWhere((t) => t.id == taskId);
      if (task.goalId != null && goalIdsBeingRemoved.contains(task.goalId)) {
        orphanFutures.add(viewModel.orphanTask(task));
      }
    }

    if (orphanFutures.isNotEmpty) {
      await Future.wait(orphanFutures);
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

    if (!context.mounted) return;

    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.reflection,
      arguments: updatedInstance,
    );
  }
}
