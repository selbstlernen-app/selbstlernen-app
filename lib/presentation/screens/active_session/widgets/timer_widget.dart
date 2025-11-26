import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/circular_time_painter.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class TimerWidget extends ConsumerStatefulWidget {
  const TimerWidget({super.key, required this.instanceId});
  final int instanceId;

  @override
  ConsumerState<TimerWidget> createState() => _$TimerWidgetState();
}

class _$TimerWidgetState extends ConsumerState<TimerWidget> {
  // Get the total time to calculate progress percentage
  int _getPhaseDuration(ActiveSessionState state) {
    switch (state.currentPhase) {
      case SessionPhase.focus:
        return (state.session!.focusTimeMin) * 60;
      case SessionPhase.shortBreak:
        return (state.session!.breakTimeMin) * 60;
      case SessionPhase.longBreak:
        return (state.session!.longBreakTimeMin) * 60;
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
  Widget build(BuildContext context) {
    final ActiveSessionState state = ref.watch(
      activeSessionViewModelProvider(widget.instanceId),
    );

    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    final int totalDuration = _getPhaseDuration(state);

    /// If we count upwards, get the total seconds passed per phase,
    /// else get the seconds remaining of a phase
    final double progress = state.countUpwards
        ? (state.currentPhaseElapsed / totalDuration)
        : (state.remainingSeconds / totalDuration);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              state.session!.title,
              style: context.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const VerticalSpace(size: SpaceSize.medium),

            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: CircularTimePainter(
                      progress: progress,
                      backgroundColor: context.colorScheme.tertiary,
                      progressColor: context.colorScheme.primary,
                      isReversed: state.countUpwards,
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      state.countUpwards
                          ? TimeUtils.formatTime(state.currentPhaseElapsed)
                          : TimeUtils.formatTime(state.remainingSeconds),
                      style: context.textTheme.headlineLarge,
                    ),

                    Text(
                      _getPhaseLabel(state.currentPhase),
                      style: context.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      'Block ${state.completedBlocks + 1}',
                      style: context.textTheme.labelSmall!.copyWith(
                        color: AppPalette.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const VerticalSpace(size: SpaceSize.large),

            _buildPhaseIndicator(state),

            const VerticalSpace(size: SpaceSize.medium),

            // Button row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Switch timer view
                CustomIconButton(
                  icon: const Icon(Icons.sync_alt_rounded),
                  isActive: true,
                  onPressed: () {
                    viewModel.setCountUpwards(!state.countUpwards);
                  },
                ),

                // Pause and continue
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: CustomIconButton(
                    radius: 40,
                    icon:
                        (state.timerStatus == TimerStatus.paused ||
                            state.timerStatus == TimerStatus.initial)
                        ? const Icon(Icons.play_arrow_rounded)
                        : const Icon(Icons.pause_rounded),
                    label: state.timerStatus == TimerStatus.initial
                        ? "Starten"
                        : null,
                    isActive: true,
                    onPressed: () {
                      if (state.timerStatus == TimerStatus.running) {
                        viewModel.pauseTimer();
                      } else {
                        viewModel.startTimer();
                      }
                    },
                  ),
                ),

                // Skip phase
                CustomIconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 25),
                  isActive: true,
                  onPressed: () {
                    viewModel.skipPhase();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(ActiveSessionState state) {
    final int focusPhases = state.session!.focusPhases;
    final int currentBlock = state.currentPhaseIndex;

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      children: List<Widget>.generate(focusPhases, (int index) {
        final int focusBlockIndex = index * 2;
        final int breakBlockIndex = focusBlockIndex + 1;
        if (index < focusPhases - 1) {
          return Container(
            margin: const EdgeInsets.only(right: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Opacity(
                  opacity: currentBlock == focusBlockIndex ? 1.0 : 0.2,
                  child: _buildPreviewBlock("F", context.colorScheme.primary),
                ),
                const HorizontalSpace(custom: 2.0),
                Opacity(
                  opacity: currentBlock == breakBlockIndex ? 1.0 : 0.2,
                  child: _buildPreviewBlock("K", context.colorScheme.primary),
                ),
              ],
            ),
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Opacity(
                opacity: currentBlock == focusBlockIndex ? 1.0 : 0.2,
                child: _buildPreviewBlock("F", context.colorScheme.primary),
              ),
              const HorizontalSpace(custom: 2.0),
              Opacity(
                opacity: currentBlock == breakBlockIndex ? 1.0 : 0.2,
                child: _buildPreviewBlock("L", context.colorScheme.primary),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildPreviewBlock(String label, Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: context.textTheme.labelSmall!.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
