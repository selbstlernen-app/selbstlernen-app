import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/segmented_toggle_button.dart';
import 'package:srl_app/common_widgets/spacing.dart';
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
  late TextEditingController _longBreakController;
  late TextEditingController _focusPhaseController;

  @override
  void initState() {
    super.initState();
    _focusController = TextEditingController();
    _breakController = TextEditingController();
    _longBreakController = TextEditingController();
    _focusPhaseController = TextEditingController();

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = ref.read(addSessionViewModelProvider);

      _focusController.text = state.focusTimeMin.toString();
      _breakController.text = state.breakTimeMin.toString();
      _longBreakController.text = state.longBreakTimeMin.toString();
      _focusPhaseController.text = state.focusPhases.toString();
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
    _longBreakController.dispose();
    _focusPhaseController.dispose();

    super.dispose();
  }

  void _saveSettings() {
    final notifier = ref.read(addSessionViewModelProvider.notifier);
    final state = ref.read(addSessionViewModelProvider);
    if (state.isSimpleTimer) {
      notifier.setTimerSettings(
        breakTime: 0,
        longBreakTime: 0,
        focusPhases: 1,
      );
    }

    // Then navigate forward
    widget.navigateForward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Zeit (in min)', style: context.textTheme.headlineMedium),
                const VerticalSpace(size: SpaceSize.xsmall),
                Text(
                  '''Lege die Zeit fest, die du in dieser Lerneinheit verbringen willst.''',
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(
                  size: SpaceSize.small,
                ),

                SegmentedToggleButton(
                  leftLabel: 'Fokus-Timer',
                  rightLabel: 'Pomodoro-Timer',
                  isLeftActive: state.isSimpleTimer,
                  onLeftPressed: () => ref
                      .read(addSessionViewModelProvider.notifier)
                      .toggleTimerMode(isSimpleTimer: true),
                  onRightPressed: () => ref
                      .read(addSessionViewModelProvider.notifier)
                      .toggleTimerMode(isSimpleTimer: false),
                ),

                const VerticalSpace(
                  size: SpaceSize.small,
                ),

                if (!state.isSimpleTimer)
                  _buildAdvancedTimeSettings()
                else
                  _buildSimpleTimeSettings(),
              ],
            ),
          ),
        ),

        SizedBox(
          width: context.mediaQuery.size.width,
          child: CustomButton(
            isActive: state.isTimeValid,
            label: 'Weiter',
            onPressed: () => state.isTimeValid ? _saveSettings() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTimeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          ],
        ),
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
    final state = ref.read(addSessionViewModelProvider);

    final focusPhases = state.focusPhases != 0 ? state.focusPhases : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Block Vorschau', style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List<Widget>.generate(focusPhases, (int index) {
            if (index < focusPhases - 1) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildPreviewBlock('F', context.colorScheme.primary),
                    const HorizontalSpace(size: SpaceSize.xsmall),
                    _buildPreviewBlock('K', context.colorScheme.secondary),
                  ],
                ),
              );
            } else {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildPreviewBlock('F', context.colorScheme.primary),
                  const HorizontalSpace(size: SpaceSize.xsmall),
                  _buildPreviewBlock('L', context.colorScheme.onTertiary),
                ],
              );
            }
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
    final state = ref.read(addSessionViewModelProvider);

    if (state.isSimpleTimer) {
      return Text(
        'Gesamtzeit: ${state.focusTimeMin} min',
      );
    }

    final focusPhases = state.focusPhases > 0 ? state.focusPhases : 1;

    final totalMins =
        (state.focusTimeMin + state.breakTimeMin) * focusPhases +
        state.longBreakTimeMin;

    if (totalMins >= 60) {
      final hours = totalMins ~/ 60;
      final mins = totalMins % 60;

      return Text('Gesamtzeit: ${hours}h $mins min');
    } else {
      return Text('Gesamtzeit: $totalMins min');
    }
  }
}
