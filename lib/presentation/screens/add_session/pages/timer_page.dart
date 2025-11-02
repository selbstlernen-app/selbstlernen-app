import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key, required this.navigateForward});
  final VoidCallback navigateForward;

  @override
  ConsumerState<TimerPage> createState() => _$TimerPageState();
}

class _$TimerPageState extends ConsumerState<TimerPage> {
  // Controllers
  final TextEditingController _focusController = TextEditingController();
  final TextEditingController _breakController = TextEditingController();
  final TextEditingController _longBreakController = TextEditingController();
  final TextEditingController _cycleController = TextEditingController();
  final TextEditingController _pomodoroController = TextEditingController();

  @override
  void dispose() {
    _focusController.dispose();
    _breakController.dispose();
    _longBreakController.dispose();
    _cycleController.dispose();
    _pomodoroController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _focusController.addListener(_updateTotalTime);
    _breakController.addListener(_updateTotalTime);
    _longBreakController.addListener(_updateTotalTime);
    _cycleController.addListener(_updateTotalTime);
    _pomodoroController.addListener(_updateTotalTime);
  }

  // To trigger rebuild of the text
  void _updateTotalTime() {
    setState(() {});
  }

  void _saveSettings() {
    // Save all Pomodoro settings
    ref
        .watch(addSessionViewModelProvider.notifier)
        .setPomodoroSettings(
          focusTime: int.tryParse(_focusController.text),
          breakTime: int.tryParse(_breakController.text),
          longBreakTime: int.tryParse(_longBreakController.text),
          cycles: int.tryParse(_cycleController.text),
        );
    // Then navigate forward
    widget.navigateForward();
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

    // Initialize empty fields on first build
    if (_focusController.text.isEmpty) {
      _focusController.text = state.focusTimeMin.toString();
      _breakController.text = state.breakTimeMin.toString();
      _longBreakController.text = state.longBreakTimeMin.toString();
      _cycleController.text = state.focusPhases.toString();
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Timer (in min)", style: context.textTheme.headlineMedium),
                const VerticalSpace(size: SpaceSize.small),
                Text(
                  "Lege die Zeit fest, die du in dieser Lerneinheit verbringen willst.",
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(size: SpaceSize.medium),

                _buildTimeSettings(),
              ],
            ),
          ),
        ),
        SizedBox(
          width: context.mediaQuery.size.width,
          child: CustomButton(
            isActive: state.isTimeValid,
            label: "Weiter",
            onPressed: () => state.isTimeValid ? _saveSettings() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TimeInputField(
                label: "Fokuszeit",
                controller: _focusController,
                onChanged: (int value) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setPomodoroSettings(focusTime: value);
                },
              ),
            ),
            TimeInputField(
              label: "Kurze Pause",
              controller: _breakController,
              onChanged: (int value) {
                ref
                    .read(addSessionViewModelProvider.notifier)
                    .setPomodoroSettings(breakTime: value);
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
                label: "Fokusphasen bis lange Pause",
                controller: _cycleController,
                onChanged: (int value) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setPomodoroSettings(cycles: value);
                },
                minValue: 0,
                maxValue: 10,
              ),
            ),

            TimeInputField(
              label: "Lange Pause",
              controller: _longBreakController,
              onChanged: (int value) {
                ref
                    .read(addSessionViewModelProvider.notifier)
                    .setPomodoroSettings(longBreakTime: value);
              },
            ),
          ],
        ),

        const VerticalSpace(size: SpaceSize.medium),

        _buildTimerPreview(),

        const VerticalSpace(size: SpaceSize.xsmall),

        Divider(
          color: context.colorScheme.tertiary,
          thickness: 4,
          radius: const BorderRadius.all(Radius.circular(10)),
        ),
        const VerticalSpace(size: SpaceSize.xsmall),

        _calculateTotalTime(),
      ],
    );
  }

  Widget _buildTimerPreview() {
    final int cycles = int.tryParse(_cycleController.text) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Zyklus Vorschau", style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List<Widget>.generate(cycles + 1, (int index) {
            if (index < cycles) {
              return Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildPreviewBlock("F", context.colorScheme.primary),
                    const HorizontalSpace(size: SpaceSize.xsmall),
                    _buildPreviewBlock("K", context.colorScheme.secondary),
                  ],
                ),
              );
            } else {
              return _buildPreviewBlock("L", context.colorScheme.onTertiary);
            }
          }),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          "F = Fokuszeit, K = Kurze Pause, L = Lange Pause",
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
    final AddSessionState state = ref.read(addSessionViewModelProvider);

    int totalMins =
        ((state.focusTimeMin + state.breakTimeMin) * state.focusPhases +
        state.longBreakTimeMin);

    if (totalMins >= 60) {
      int hours = totalMins ~/ 60;
      int mins = totalMins % 60;

      return Text("Zeit insgesamt: ${hours}h ${mins}m");
    } else {
      return Text("Zeit insgesamt: ${totalMins}m");
    }
  }
}
