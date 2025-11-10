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
      final AddSessionState state = ref.read(addSessionViewModelProvider);

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
    ref
        .watch(addSessionViewModelProvider.notifier)
        .setPomodoroSettings(
          focusTime: int.tryParse(_focusController.text) ?? 0,
          breakTime: int.tryParse(_breakController.text) ?? 0,
          longBreakTime: int.tryParse(_longBreakController.text) ?? 0,
          focusPhases: int.tryParse(_focusPhaseController.text) ?? 1,
        );
    // Then navigate forward
    widget.navigateForward();
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

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
                controller: _focusPhaseController,
                onChanged: (int value) {
                  ref
                      .read(addSessionViewModelProvider.notifier)
                      .setPomodoroSettings(focusPhases: value);
                },
                minValue: 1,
                maxValue: 15,
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
    final AddSessionState state = ref.read(addSessionViewModelProvider);

    int focusPhases = state.focusPhases != 0 ? state.focusPhases : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Zyklus Vorschau", style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List<Widget>.generate(focusPhases, (int index) {
            if (index < focusPhases - 1) {
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
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildPreviewBlock("F", context.colorScheme.primary),
                  const HorizontalSpace(size: SpaceSize.xsmall),
                  _buildPreviewBlock("L", context.colorScheme.onTertiary),
                ],
              );
            }
          }),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          "F = Fokusphase, K = Kurze Pause, L = Lange Pause",
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

    int focusPhases = state.focusPhases != 0 ? state.focusPhases : 1;

    int totalMins =
        ((state.focusTimeMin + state.breakTimeMin) * focusPhases +
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
