import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/circular_time_painter.dart';
import 'package:srl_app/presentation/screens/active_session/widgets/goals_page.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key, required this.fullSessionModel});

  final FullSessionModel fullSessionModel;

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  late SessionInstanceModel sessionInstance;

  @override
  void initState() {
    super.initState();
    _initializeSessionInstance();
  }

  Future<void> _initializeSessionInstance() async {}

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _getPhaseDuration(ActiveSessionState state) {
    switch (state.currentPhase) {
      case SessionPhase.focus:
        return (state.fullSession.session.focusTimeMin) * 60;
      case SessionPhase.shortBreak:
        return (state.fullSession.session.breakTimeMin) * 60;
      case SessionPhase.longBreak:
        return (state.fullSession.session.longBreakTimeMin) * 60;
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
      activeSessionViewModelProvider(widget.fullSessionModel),
    );
    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(widget.fullSessionModel).notifier,
    );

    return Scaffold(
      backgroundColor: context.colorScheme.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        state.fullSession.session.title,
                        style: context.textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      Text(
                        _getPhaseLabel(state.currentPhase),
                        style: context.textTheme.titleLarge,
                      ),

                      const VerticalSpace(size: SpaceSize.medium),

                      Text(
                        'Fokusphase ${state.totalFocusPhases + 1} | Block ${state.completedBlocks + 1}',
                        style: context.textTheme.titleMedium,
                      ),

                      const VerticalSpace(size: SpaceSize.large),

                      // Horizontally scrollable timer and goals
                      SizedBox(
                        height: 350,
                        child: PageView(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: _buildTimerPage(context, state),
                            ),
                            GoalsPage(
                              fullSessionModel: widget.fullSessionModel,
                            ),
                          ],
                        ),
                      ),

                      const VerticalSpace(size: SpaceSize.medium),

                      // Pause and skip button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Pause and continue
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: context.colorScheme.primary,
                            child: IconButton(
                              icon:
                                  (state.timerStatus == TimerStatus.paused ||
                                      state.timerStatus == TimerStatus.initial)
                                  ? const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 35,
                                    )
                                  : const Icon(Icons.pause_rounded, size: 35),
                              color: Colors.white,

                              onPressed: () {
                                if (state.timerStatus == TimerStatus.running) {
                                  viewModel.pauseTimer();
                                } else {
                                  viewModel.startTimer();
                                }
                              },
                            ),
                          ),

                          const HorizontalSpace(size: SpaceSize.large),

                          // Skip phase
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: context.colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.skip_next_rounded,
                                size: 35,
                              ),
                              color: Colors.white,
                              onPressed: () {
                                viewModel.skipPhase();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Fokuszeit insgesamt:',
                        style: context.textTheme.bodyMedium,
                      ),
                      Text(_formatTime(state.totalFocusSecondsElapsed)),
                    ],
                  ),
                ),
              ),

              const VerticalSpace(size: SpaceSize.medium),

              // Start and stop button
              SizedBox(
                width: context.mediaQuery.size.width,
                child: CustomButton(
                  onPressed: () async {
                    if (state.timerStatus == TimerStatus.initial) {
                      viewModel.startTimer();
                    }
                    if (state.timerStatus != TimerStatus.initial) {
                      await viewModel.stopSession();
                      if (context.mounted) {
                        context.scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 2),
                            content: Text("Einheit erfolgreich abgeschlossen!"),
                          ),
                        );
                        await Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                const MainNavigation(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    }
                  },
                  label: state.timerStatus == TimerStatus.initial
                      ? "Lerneinheit beginnen"
                      : 'Lerneinheit beenden',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerPage(BuildContext context, ActiveSessionState state) {
    final int totalDuration = _getPhaseDuration(state);
    final double progress = state.remainingSeconds / totalDuration;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: context.mediaQuery.size.width,
            height: context.mediaQuery.size.width,
            child: CustomPaint(
              painter: CircularTimePainter(
                progress: progress,
                backgroundColor: context.colorScheme.onPrimary,
                progressColor: context.colorScheme.primary,
              ),
            ),
          ),
          Text(
            _formatTime(state.remainingSeconds),
            style: context.textTheme.headlineLarge?.copyWith(fontSize: 48),
          ),
        ],
      ),
    );
  }
}
