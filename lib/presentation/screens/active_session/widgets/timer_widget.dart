import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/circular_timer/progress_circle.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class TimerWidget extends ConsumerStatefulWidget {
  const TimerWidget({required this.instanceId, super.key});
  final int instanceId;

  @override
  ConsumerState<TimerWidget> createState() => _$TimerWidgetState();
}

class _$TimerWidgetState extends ConsumerState<TimerWidget> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();

    _lifecycleListener = AppLifecycleListener(
      onDetach: () async {
        await ref.read(settingsRepositoryProvider).setTimerEndTimestamp(null);
      },
      onStateChange: (lifecycleState) async {
        if (!mounted) return;

        final notifier = ref.read(
          activeSessionViewModelProvider(widget.instanceId).notifier,
        );
        final repo = ref.read(settingsRepositoryProvider);

        if (ref
                .read(activeSessionViewModelProvider(widget.instanceId))
                .timerStatus ==
            TimerStatus.running) {
          if (lifecycleState == AppLifecycleState.paused ||
              lifecycleState == AppLifecycleState.detached) {
            final currentState = ref.read(
              activeSessionViewModelProvider(widget.instanceId),
            );

            // Both platforms save timestamp on leave
            final targetEndTime = DateTime.now().add(
              Duration(seconds: currentState.remainingSeconds),
            );

            await repo.setTimerEndTimestamp(targetEndTime);
          } else if (lifecycleState == AppLifecycleState.resumed) {
            // Both platoforms sync timer based on last recorded timestamp
            if (repo.timerEndTimestamp != null) {
              await notifier.syncTimerAfterBackground();
            }
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
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
    final completedBlocks = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.completedBlocks),
    );

    final isSimpleTimer = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) {
        return s.session!.complexity == SessionComplexity.simple;
      }),
    );

    final sessionTitle = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.session?.title ?? ''),
    );

    final currentPhase = ref.watch(
      activeSessionViewModelProvider(
        widget.instanceId,
      ).select((s) => s.currentPhase),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text(
              sessionTitle,
              style: context.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),

            const VerticalSpace(),

            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 160,
                  height: 160,
                  child: ProgressCircle(instanceId: widget.instanceId),
                ),
                Column(
                  children: [
                    TimeTicker(instanceId: widget.instanceId),

                    Text(
                      _getPhaseLabel(currentPhase),
                      style: context.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Text(
                      '${isSimpleTimer ? "Runde" : "Block"} ${completedBlocks + 1}',
                      style: context.textTheme.labelSmall!.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const VerticalSpace(size: SpaceSize.large),

            if (!isSimpleTimer) _PhaseIndicator(instanceId: widget.instanceId),

            const VerticalSpace(),

            // Button row
            _TimerButtons(instanceId: widget.instanceId),
          ],
        ),
      ),
    );
  }
}

// Class for the time running down to reduce rebuilds of full screen
class TimeTicker extends ConsumerWidget {
  const TimeTicker({required this.instanceId, super.key});
  final int instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayTime = ref.watch(
      activeSessionViewModelProvider(instanceId).select((s) {
        return s.countUpwards ? s.currentPhaseElapsed : s.remainingSeconds;
      }),
    );

    return Text(
      TimeUtils.formatTime(displayTime),
      style: context.textTheme.headlineLarge,
    );
  }
}

class _TimerButtons extends ConsumerWidget {
  const _TimerButtons({required this.instanceId});
  final int instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countUpwards = ref.watch(
      activeSessionViewModelProvider(
        instanceId,
      ).select((s) => s.countUpwards),
    );

    final timerStatus = ref.watch(
      activeSessionViewModelProvider(
        instanceId,
      ).select((s) => s.timerStatus),
    );

    final timerStartsAutomatically = ref.watch(
      settingsViewModelProvider.select((s) => s.timerStartsAutomatically),
    );

    final viewModel = ref.read(
      activeSessionViewModelProvider(instanceId).notifier,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Switch timer view
        CustomIconButton(
          icon: const Icon(Icons.sync_alt_rounded),
          isActive: true,
          onPressed: () {
            viewModel.setCountUpwards(
              countUpwards: !countUpwards,
            );
          },
        ),

        // Pause and continue
        if (timerStartsAutomatically)
          CustomIconButton(
            radius: 40,
            icon:
                (timerStatus == TimerStatus.paused ||
                    timerStatus == TimerStatus.initial)
                ? const Icon(Icons.play_arrow_rounded)
                : const Icon(Icons.pause_rounded),
            onPressed: () async {
              if (timerStatus == TimerStatus.running) {
                await viewModel.pauseTimer();
              } else {
                await viewModel.startTimer();
              }
            },
            isActive: true,
          )
        else
          // If not set automatically starting, show "Starten" explicitly
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: CustomIconButton(
              radius: 40,
              icon:
                  (timerStatus == TimerStatus.paused ||
                      timerStatus == TimerStatus.initial)
                  ? const Icon(Icons.play_arrow_rounded)
                  : const Icon(Icons.pause_rounded),
              label: timerStatus == TimerStatus.initial ? 'Starten' : null,
              isActive: true,
              onPressed: () async {
                if (timerStatus == TimerStatus.running) {
                  await viewModel.pauseTimer();
                } else {
                  await viewModel.startTimer();
                }
              },
            ),
          ),

        // Skip phase
        CustomIconButton(
          icon: const Icon(Icons.skip_next_rounded, size: 25),
          isActive: true,
          onPressed: timerStatus == TimerStatus.initial
              ? null
              : viewModel.skipPhase,
        ),
      ],
    );
  }
}

class _PhaseIndicator extends ConsumerWidget {
  const _PhaseIndicator({required this.instanceId});
  final int instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBlock = ref.watch(
      activeSessionViewModelProvider(
        instanceId,
      ).select((s) => s.currentPhaseIndex),
    );
    final focusPhases = ref.watch(
      activeSessionViewModelProvider(
        instanceId,
      ).select((s) => s.session!.focusPhases),
    );
    return Wrap(
      runSpacing: 4,
      children: List<Widget>.generate(focusPhases, (int index) {
        final focusBlockIndex = index * 2;
        final breakBlockIndex = focusBlockIndex + 1;
        if (index < focusPhases - 1) {
          return Container(
            margin: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Opacity(
                  opacity: currentBlock == focusBlockIndex ? 1.0 : 0.2,
                  child: _buildPreviewBlock(
                    context,
                    'F',
                    context.colorScheme.primary,
                  ),
                ),
                const HorizontalSpace(custom: 2),
                Opacity(
                  opacity: currentBlock == breakBlockIndex ? 1.0 : 0.2,
                  child: _buildPreviewBlock(
                    context,
                    'K',
                    context.colorScheme.primary,
                  ),
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
                child: _buildPreviewBlock(
                  context,
                  'F',
                  context.colorScheme.primary,
                ),
              ),
              const HorizontalSpace(custom: 2),
              Opacity(
                opacity: currentBlock == breakBlockIndex ? 1.0 : 0.2,
                child: _buildPreviewBlock(
                  context,
                  'L',
                  context.colorScheme.primary,
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildPreviewBlock(BuildContext context, String label, Color color) {
    return Container(
      width: 17,
      height: 17,
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
