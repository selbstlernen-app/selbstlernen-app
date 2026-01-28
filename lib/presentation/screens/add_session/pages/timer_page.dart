import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _$TimerPageState();
}

class _$TimerPageState extends ConsumerState<TimerPage> {
  // Controllers
  late TextEditingController _focusController;
  late TextEditingController _breakController;
  late TextEditingController _longBreakController;
  late TextEditingController _focusPhaseController;

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController();
    _breakController = TextEditingController();
    _longBreakController = TextEditingController();
    _focusPhaseController = TextEditingController();

    _focusController.text = ref
        .read(addSessionViewModelProvider)
        .focusTimeMin
        .toString();
    _breakController.text = ref
        .read(addSessionViewModelProvider)
        .breakTimeMin
        .toString();
    _longBreakController.text = ref
        .read(addSessionViewModelProvider)
        .longBreakTimeMin
        .toString();
    _focusPhaseController.text = ref
        .read(addSessionViewModelProvider)
        .focusPhases
        .toString();
  }

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
    _longBreakController.dispose();
    _focusPhaseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTimeValid = ref.watch(
      addSessionViewModelProvider.select((s) => s.isTimeValid),
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
              ],
            ),
          ),
        ),

        SizedBox(
          width: double.infinity,
          child: CustomButton(
            isActive: isTimeValid,
            label: 'Weiter',
            onPressed: () => isTimeValid
                ? ref
                      .read(addSessionPageControllerProvider)
                      .nextPage(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                      )
                : null,
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
                label: 'Fokusphasen bis zur langen Pause',
                controller: _focusPhaseController,
                onChanged: (int value) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTimerSettings(focusPhases: value);
                },
                maxValue: 15,
              ),
            ),

            TimeInputField(
              label: 'Lange Pause',
              controller: _longBreakController,
              onChanged: (int value) {
                ref
                    .read(addSessionViewModelProvider.notifier)
                    .setTimerSettings(longBreakTime: value);
              },
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
      addSessionViewModelProvider.select((s) => s.focusPhases),
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
            color: context.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _calculateTotalTime() {
    final (focus, short, long, phases) = ref.watch(
      addSessionViewModelProvider.select(
        (s) =>
            (s.focusTimeMin, s.breakTimeMin, s.longBreakTimeMin, s.focusPhases),
      ),
    );

    final actualPhases = phases > 0 ? phases : 1;
    // Calculates (F+K) * (Phases - 1) + F + L
    // The long break counts as its own
    final totalMins = (focus + short) * (actualPhases - 1) + focus + long;

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
