import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/exit_button.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/goals_list_widget.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/timer_widget.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({
    required this.instanceId,
    required this.sessionId,
    super.key,
  });

  final int instanceId;
  final int sessionId;

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  late SessionInstanceModel sessionInstance;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      activeSessionViewModelProvider(widget.instanceId),
    );

    if (state.isLoading) {
      return const LoadingIndicator();
    }

    // Handle error
    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${state.error}')));
    }

    // Handle no data
    if (state.session == null || state.instance == null) {
      return const Scaffold(
        body: Center(child: Text('Session nicht gefunden')),
      );
    }

    return Scaffold(
      backgroundColor: context.colorScheme.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TimerWidget(instanceId: widget.instanceId),
                      const VerticalSpace(size: SpaceSize.small),
                      GoalsListWidget(instanceId: widget.instanceId),
                    ],
                  ),
                ),
              ),

              // Stop session button
              if (state.timerStatus != TimerStatus.initial) ...<Widget>[
                const VerticalSpace(size: SpaceSize.small),
                ExitButton(instanceId: widget.instanceId),
              ],

              // Leave session button
              if (state.timerStatus == TimerStatus.initial) ...<Widget>[
                const VerticalSpace(size: SpaceSize.small),
                SizedBox(
                  width: context.mediaQuery.size.width,
                  child: CustomButton(
                    verticalPadding: 8,
                    onPressed: () async {
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              const MainNavigation(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    label: 'Lerneinheit verlassen',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
