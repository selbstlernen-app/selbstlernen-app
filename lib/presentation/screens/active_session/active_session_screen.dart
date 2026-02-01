import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/exit_button.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/focus_prompt_dialog.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/goals_list_widget.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/timer_widget.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({
    required this.instanceId,
    required this.sessionId,
    super.key,
  });

  final int instanceId;
  final int sessionId;

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  late SessionInstanceModel sessionInstance;

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  Future<void> _handleTimerStatusChange(TimerStatus status) async {
    if (status == TimerStatus.running || status == TimerStatus.initial) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Focus prompt + wakelock listener
    ref.listen<ActiveSessionState>(
      activeSessionViewModelProvider(widget.instanceId),
      (previous, next) async {
        // Show dialog when showFocusPrompt becomes true
        if (next.showFocusPrompt && !(previous?.showFocusPrompt ?? false)) {
          await _showFocusPromptDialog(
            ref.read(
              activeSessionViewModelProvider(widget.instanceId).notifier,
            ),
          );
          if (!mounted) return;
        }
        // Stop wakelock when timer status is NOT running
        if (previous?.timerStatus != next.timerStatus) {
          await _handleTimerStatusChange(next.timerStatus);
        }
      },
    );

    final isLoading = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.isLoading),
    );
    final error = ref.watch(
      activeSessionViewModelProvider(widget.instanceId).select((s) => s.error),
    );
    final hasData = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.session != null),
    );
    final timerStatus = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.timerStatus),
    );

    if (isLoading) return const LoadingIndicator();
    if (error != null) {
      return Scaffold(body: Center(child: Text('Fehler: $error')));
    }
    if (!hasData) {
      return const Scaffold(
        body: Center(child: Text('Session nicht gefunden')),
      );
    }

    return Listener(
      onPointerDown: (_) => ref
          .read(activeSessionViewModelProvider(widget.instanceId).notifier)
          .recordUserInteraction(),
      child: Scaffold(
        backgroundColor: Color.lerp(
          context.colorScheme.secondary,
          Colors.white,
          0.1,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TimerWidget(instanceId: widget.instanceId),
                        const VerticalSpace(size: SpaceSize.small),
                        GoalsListWidget(instanceId: widget.instanceId),
                      ],
                    ),
                  ),
                ),

                // Stop session button
                if (timerStatus != TimerStatus.initial) ...<Widget>[
                  const VerticalSpace(size: SpaceSize.small),
                  ExitButton(instanceId: widget.instanceId),
                ],

                // Leave session button
                if (timerStatus == TimerStatus.initial) ...<Widget>[
                  const VerticalSpace(size: SpaceSize.small),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      verticalPadding: 8,
                      onPressed: () async {
                        await Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                const MainNavigation(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      label: 'Lerneinheit verlassen',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFocusPromptDialog(ActiveSessionViewModel viewModel) async {
    await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FocusPromptDialog(
        onFocusLevelSelected: viewModel.recordFocusLevel,
      ),
    );
  }
}
