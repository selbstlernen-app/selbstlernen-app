import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/circular_time_painter.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key, required this.fullSessionModel});

  final FullSessionModel fullSessionModel;

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _getPhaseDuration(ActiveSessionState state) {
    switch (state.currentPhase) {
      case SessionPhase.focus:
        return (state.fullSession.session.focusTimeMin) * 60;
      case SessionPhase.shortBreak:
        return (state.fullSession.session.breakTimeMin) * 60;
      case SessionPhase.longBreak:
        return (state.fullSession.session.longBreakTimeMin) * 60;
    }
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

    final int totalDuration = _getPhaseDuration(state);
    final double progress = state.remainingSeconds / totalDuration;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: CircularTimePainter(
                      progress: progress,
                      backgroundColor: context.colorScheme.onPrimary,
                      progressColor: context.colorScheme.primary,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      _formatTime(state.remainingSeconds),
                      style: context.textTheme.headlineLarge?.copyWith(
                        fontSize: 48,
                      ),
                    ),
                    Text(
                      _getPhaseLabel(state.currentPhase),
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Pause and skip button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Pause and continue
            CircleAvatar(
              radius: 25,
              backgroundColor: context.colorScheme.primary,
              child: IconButton(
                icon:
                    (state.timerStatus == TimerStatus.paused ||
                        state.timerStatus == TimerStatus.initial)
                    ? const Icon(Icons.play_arrow_rounded, size: 35)
                    : const Icon(Icons.pause_rounded, size: 35),
                color: Colors.white,

                onPressed: () {
                  if (state.timerStatus == TimerStatus.running) {
                    viewModel.pauseTimer();
                  } else {
                    viewModel.startTimer();
                  }
                },
              ),
            ),

            const HorizontalSpace(size: SpaceSize.large),

            // Skip phase
            CircleAvatar(
              radius: 25,
              backgroundColor: context.colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 35),
                color: Colors.white,
                onPressed: () {
                  viewModel.skipPhase();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
