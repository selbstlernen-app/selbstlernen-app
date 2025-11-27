import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_item_tile.dart';
import 'package:srl_app/common_widgets/show_custom_dialog.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
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

      // Get newly added items
      final List<GoalModel> newGoals = state.newlyAddedGoals;
      final List<TaskModel> newTasks = state.newlyAddedTasks;

      // Default for repeating sessions is to keep; for one-time sessions this is always false (no switch)
      bool keepNewItems = state.session?.isRepeating == true;

      await showCustomDialog(
        context: context,
        title: "Lerneinheit beenden",
        content: StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Willst du diese Lerneinheit wirklich beenden?",
                  style: context.textTheme.bodyMedium,
                ),

                // Show newly added items if any; only for repeating sessions
                if (state.session!.isRepeating &&
                    (newGoals.isNotEmpty || newTasks.isNotEmpty)) ...<Widget>[
                  const VerticalSpace(size: SpaceSize.medium),
                  Text(
                    "Neue Elemente für diese Einheit:",
                    style: context.textTheme.labelLarge,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  if (newGoals.isNotEmpty)
                    ...newGoals.map(
                      (GoalModel g) =>
                          CustomItemTile(text: g.title, isLargeGoal: true),
                    ),

                  if (newTasks.isNotEmpty)
                    ...newTasks.map(
                      (TaskModel t) =>
                          CustomItemTile(text: t.title, isLargeGoal: false),
                    ),

                  const VerticalSpace(size: SpaceSize.small),

                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          "Neue Elemente für zukünftige Sitzungen behalten",
                        ),
                      ),
                      Switch(
                        value: keepNewItems,
                        onChanged: (bool value) {
                          setState(() {
                            keepNewItems = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  Text(
                    keepNewItems
                        ? "Neue Ziele und Aufgaben werden in der nächsten Einheit übertragen"
                        : "Neue Ziele und Aufgaben werden als abgeschlossen markiert",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppPalette.grey,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        confirmLabel: "Bestätigen",
        onCancel: () {
          // User cancelled - resume timer
          viewModel.startTimer();
          // Reset exit button
          setState(() => _tappedOnce = false);
        },
        onConfirm: () async {
          final SessionInstanceModel updatedInstance = await viewModel
              .completeSession(keepNewlyAddedItems: keepNewItems);

          if (!mounted) return;
          await Navigator.pushReplacementNamed(
            context,
            AppRoutes.reflection,
            arguments: updatedInstance,
          );
        },
        cancelLabel: "Abbrechen",
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
