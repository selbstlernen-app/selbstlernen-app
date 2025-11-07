import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/active_session/pages/goals_page.dart';
import 'package:srl_app/presentation/screens/active_session/pages/timer_page.dart';
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
  final controller = PageController(initialPage: 0);

  final List<Widget> pages = <Widget>[];

  @override
  void initState() {
    super.initState();

    _initializeSessionInstance();

    pages.addAll(<Widget>[
      TimerPage(fullSessionModel: widget.fullSessionModel),
      GoalsPage(fullSessionModel: widget.fullSessionModel),
    ]);
  }

  Future<void> _initializeSessionInstance() async {
    await ref
        .read(activeSessionViewModelProvider(widget.fullSessionModel).notifier)
        .initializeSession();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const VerticalSpace(size: SpaceSize.large),
                      Text(
                        state.fullSession.session.title,
                        style: context.textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const VerticalSpace(size: SpaceSize.medium),
                      Text(
                        'Fokusphase ${state.totalFocusPhases + 1} | Block ${state.completedBlocks + 1}',
                        style: context.textTheme.titleMedium,
                      ),

                      // Horizontally scrollable pages
                      SizedBox(
                        height: context.mediaQuery.size.height / 2,
                        child: PageView.builder(
                          controller: controller,
                          itemCount: pages.length,
                          itemBuilder: (_, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: pages[index % pages.length],
                            );
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: pages.length,
                          effect: WormEffect(
                            dotHeight: 16,
                            dotWidth: 16,
                            type: WormType.thinUnderground,
                            dotColor: context.colorScheme.tertiary,
                            activeDotColor: context.colorScheme.primary,
                          ),
                        ),
                      ),
                      const VerticalSpace(size: SpaceSize.medium),

                      // Total time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Fokuszeit insgesamt:',
                            style: context.textTheme.bodyMedium,
                          ),
                          Text(
                            TimeUtils.formatTime(
                              state.totalFocusSecondsElapsed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Start and stop button
              CustomButton(
                verticalPadding: 8.0,
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
                      // TODO: push to finish screen
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
            ],
          ),
        ),
      ),
    );
  }
}
