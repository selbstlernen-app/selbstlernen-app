import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
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
                  'Pomodoro Timer festlegen',
                  style: context.textTheme.headlineSmall,
                ),
              ],
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            _buildAdvancedTimeSettings(),
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
              label: 'Kurze Pause',
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
                maxValue: 15,
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

        _calculateTotalTime(),
      ],
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
        Text('Block Vorschau', style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List<Widget>.generate(actualPhases, (int index) {
            final isLast = index == actualPhases - 1;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildPreviewBlock('F', context.colorScheme.primary),
                const HorizontalSpace(size: SpaceSize.xsmall),
                if (!isLast)
                  _buildPreviewBlock('K', context.colorScheme.secondary)
                else
                  _buildPreviewBlock('L', context.colorScheme.tertiary),
              ],
            );
          }),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          'F = Fokusphase, K = Kurze Pause, L = Lange Pause',
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPreviewBlock(String label, Color color) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: context.textTheme.labelLarge!.copyWith(
            color: label != 'L'
                ? context.colorScheme.onPrimary
                : context.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _calculateTotalTime() {
    final (focus, short, phases) = ref.watch(
      addSessionViewModelProvider.select(
        (s) => (s.focusTimeMin, s.breakTimeMin, s.pomodoroPhases),
      ),
    );

    // Calculates (F+K) * (Phases)
    // The long break counts as its own
    final totalMins = (focus + short) * phases;

    final duration = Duration(minutes: totalMins);
    final hours = duration.inHours;
    final mins = duration.inMinutes % 60;

    return Text(
      'Gesamtzeit: ${hours > 0 ? '${hours}h ' : ''}$mins min',
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
