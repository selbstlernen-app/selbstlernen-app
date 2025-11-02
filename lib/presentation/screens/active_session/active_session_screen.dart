import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class ActiveSessionScreen extends ConsumerWidget {
  const ActiveSessionScreen({super.key, required this.fullSessionModel});

  final FullSessionModel fullSessionModel;

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getPhaseLabel(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.focus:
        return 'Fokuszeit';
      case SessionPhase.shortBreak:
        return 'Kurze Pause';
      case SessionPhase.longBreak:
        return 'Lange Pause';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActiveSessionState state = ref.watch(
      activeSessionViewModelProvider(fullSessionModel),
    );
    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(fullSessionModel).notifier,
    );

    return Scaffold(
      backgroundColor: context.colorScheme.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                state.fullSession.session.title,
                style: context.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const VerticalSpace(size: SpaceSize.small),
              Text(
                _getPhaseLabel(state.currentPhase),
                style: context.textTheme.titleLarge,
              ),
              const VerticalSpace(size: SpaceSize.large),
              Text(
                _formatTime(state.remainingSeconds),
                style: context.textTheme.displayLarge?.copyWith(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Fokusphase ${state.totalFocusPhases + 1} | Zyklus ${state.completedCycles + 1}',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (state.timerStatus == TimerStatus.initial ||
                      state.timerStatus == TimerStatus.paused)
                    CustomButton(
                      onPressed: viewModel.startTimer,
                      label: state.timerStatus == TimerStatus.initial
                          ? 'Start'
                          : 'Weiter',
                    ),
                  if (state.timerStatus == TimerStatus.running) ...<Widget>[
                    CustomButton(
                      onPressed: viewModel.pauseTimer,
                      label: 'Pause',
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (state.timerStatus != TimerStatus.initial)
                    CustomButton(
                      onPressed: () async {
                        await viewModel.stopSession();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      label: 'Stop',
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('Fokuszeit:'),
                      Text(_formatTime(state.totalFocusSecondsElapsed)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
