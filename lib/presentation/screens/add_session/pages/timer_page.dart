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
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Timer", style: context.textTheme.headlineMedium),
                const VerticalSpace(size: SpaceSize.small),
                Text(
                  "Trage die Zeit ein, die du in dieser Lerneinheit verbringen willst.",
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(size: SpaceSize.medium),

                // Mode toggle buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setIsPomodoro(true),
                        isActive: state.isPomodoro,
                        verticalPadding: 8.0,
                        label: "Pomodoro",
                        borderLeft: true,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setIsPomodoro(false),
                        isActive: !state.isPomodoro,
                        verticalPadding: 8.0,
                        label: "Benutzerdefiniert",
                        borderRight: true,
                      ),
                    ),
                  ],
                ),

                const VerticalSpace(size: SpaceSize.large),
                if (state.isPomodoro) _buildPomodoroView(),
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

  Widget _buildPomodoroView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TimeInputField(controller: _focusController),
        TimeInputField(controller: _breakController),
        TimeInputField(controller: _longBreakController),
        TimeInputField(controller: _cycleController),
      ],
    );
  }
}
