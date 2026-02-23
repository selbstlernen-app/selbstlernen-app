import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/common_widgets/timer_widgets.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<TimerPage> createState() => _$TimerPageState();
}

class _$TimerPageState extends ConsumerState<TimerPage> {
  // Controllers
  late TextEditingController _focusController;
  late TextEditingController _breakController;
  late TextEditingController _pomodoroPhaseController;

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController();
    _breakController = TextEditingController();
    _pomodoroPhaseController = TextEditingController();

    _focusController.text = ref
        .read(addSessionViewModelProvider)
        .focusTimeMin
        .toString();
    _breakController.text = ref
        .read(addSessionViewModelProvider)
        .breakTimeMin
        .toString();

    _pomodoroPhaseController.text = ref
        .read(addSessionViewModelProvider)
        .pomodoroPhases
        .toString();
  }

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
    _pomodoroPhaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTimeValid = ref.watch(
      addSessionViewModelProvider.select((s) => s.isTimeValid),
    );

    final isSimpleTimer = ref.watch(
      addSessionViewModelProvider.select(
        (s) => s.sessionComplexity == SessionComplexity.simple,
      ),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: <Widget>[
                const Icon(
                  Icons.timer_outlined,
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Text(
                  isSimpleTimer
                      ? 'Fokuszeit festlegen'
                      : 'Pomodoro Timer festlegen',
                  style: context.textTheme.headlineSmall,
                ),
              ],
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            // Simple Timer (*IF chosen in wizard)
            if (isSimpleTimer)
              _buildSimpleTimeSettings()
            else
              _buildAdvancedTimeSettings(),

            const VerticalSpace(),

            _InfoBox(),
          ]),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    isActive: isTimeValid,
                    label: 'Weiter',
                    onPressed: () =>
                        isTimeValid ? widget.navigateForward() : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTimeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimeInputField(
          controller: _focusController,
          onChanged: (int value) {
            ref
                .read(addSessionViewModelProvider.notifier)
                .setTimerSettings(focusTime: value);
          },
        ),

        const VerticalSpace(size: SpaceSize.xsmall),

        Divider(
          color: context.colorScheme.tertiary,
          thickness: 4,
          radius: BorderRadius.circular(10),
        ),
        const VerticalSpace(size: SpaceSize.xsmall),

        _calculateTotalTime(isSimpleTimer: true),
      ],
    );
  }

  Widget _buildAdvancedTimeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TimeInputField(
                label: 'Fokuszeit',
                controller: _focusController,
                onChanged: (int value) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTimerSettings(focusTime: value);
                },
              ),
            ),
            TimeInputField(
              label: 'Pausenzeit',
              controller: _breakController,
              onChanged: (int value) {
                ref
                    .read(addSessionViewModelProvider.notifier)
                    .setTimerSettings(breakTime: value);
              },
            ),
          ],
        ),

        const VerticalSpace(size: SpaceSize.xsmall),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TimeInputField(
                label: 'Pomodoro-Phasen',
                controller: _pomodoroPhaseController,
                onChanged: (int value) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTimerSettings(pomodoroPhases: value);
                },
                maxValue: 10,
              ),
            ),
          ],
        ),

        const VerticalSpace(size: SpaceSize.small),

        _buildTimerPreview(),

        const VerticalSpace(size: SpaceSize.xsmall),

        Divider(
          color: context.colorScheme.tertiary,
          thickness: 4,
          radius: BorderRadius.circular(10),
        ),

        const VerticalSpace(size: SpaceSize.xsmall),

        _calculateTotalTime(isSimpleTimer: false),
      ],
    );
  }

  Widget _InfoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 24,
            color: context.colorScheme.primary,
          ),
          const HorizontalSpace(size: SpaceSize.small),
          const Expanded(
            child: Text(
              '''Nach Ablauf der Zeit, kann die Einheit entweder fortgeführt oder beendet werden.''',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPreview() {
    final phases = ref.watch(
      addSessionViewModelProvider.select((s) => s.pomodoroPhases),
    );
    final actualPhases = phases > 0 ? phases : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Vorschau der Zeitaufteilung',
          style: context.textTheme.headlineSmall,
        ),
        const VerticalSpace(size: SpaceSize.small),
        Wrap(
          spacing: 6,
          runSpacing: 8,
          children: List<Widget>.generate(actualPhases, (int index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PreviewBlock(
                  color: context.colorScheme.primary,
                  label: 'F',
                  size: 25,
                ),
                const HorizontalSpace(
                  custom: 2,
                ),
                PreviewBlock(
                  color: context.colorScheme.secondary,
                  label: 'P',
                  size: 25,
                ),
              ],
            );
          }),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          'F = Fokus, P = Pause',
          style: context.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _calculateTotalTime({required bool isSimpleTimer}) {
    final (focus, short, phases) = ref.watch(
      addSessionViewModelProvider.select(
        (s) => (s.focusTimeMin, s.breakTimeMin, s.pomodoroPhases),
      ),
    );

    var totalMins = 0;
    if (isSimpleTimer) {
      totalMins = focus;
    } else {
      totalMins = (focus + short) * phases;
    }

    final duration = Duration(minutes: totalMins);
    final hours = duration.inHours;
    final mins = duration.inMinutes % 60;

    return Text(
      'Gesamtzeit: ${hours > 0 ? '${hours}h ' : ''}$mins min',
      style: context.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
