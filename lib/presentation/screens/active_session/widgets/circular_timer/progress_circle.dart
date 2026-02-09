import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/circular_timer/circular_time_painter.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

/// Widget holding the progress circle displayed on the active session screen
class ProgressCircle extends ConsumerWidget {
  const ProgressCircle({required this.instanceId, super.key});
  final int instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      activeSessionViewModelProvider(instanceId).select((s) {
        final total = _getPhaseDuration(s);
        if (total == 0) return 0.0;

        return s.countUpwards
            ? (s.currentPhaseElapsed / total)
            : (s.remainingSeconds / total);
      }),
    );

    final isReversed = ref.watch(
      activeSessionViewModelProvider(instanceId).select((s) => s.countUpwards),
    );

    return RepaintBoundary(
      // To prevent rest repainting
      child: CustomPaint(
        painter: CircularTimePainter(
          progress: progress,
          backgroundColor: context.colorScheme.tertiary,
          progressColor: context.colorScheme.primary,
          isReversed: isReversed,
        ),
      ),
    );
  }

  // Get the total time to calculate progress percentage
  int _getPhaseDuration(ActiveSessionState state) {
    final session = state.session;
    if (session == null) return 1;

    switch (state.currentPhase) {
      case SessionPhase.focus:
        return (state.session!.focusTimeMin) * 60;
      case SessionPhase.shortBreak:
        return (state.session!.breakTimeMin) * 60;
    }
  }
}
