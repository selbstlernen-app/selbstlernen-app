import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_prompt_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_time_spent/focus_time_spent_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/goal_task_completion/goal_task_completion_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/mood/mood_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/progress_card.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_view_model.dart';

class SessionStatisticsScreen extends ConsumerWidget {
  const SessionStatisticsScreen({
    required this.sessionId,
    required this.showGeneralStatsOnly,
    super.key,
  });

  final int sessionId;
  final bool showGeneralStatsOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      sessionStatisticsViewModelProvider(sessionId),
    );

    return _buildBody(context, ref, state);
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SessionStatisticsState state,
  ) {
    // Loading
    if (state.isLoading && state.stats == null && state.instances == null) {
      return const LoadingIndicator();
    }

    // Error
    if (state.error != null && state.stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const VerticalSpace(),
            Text('Fehler: ${state.error}'),
          ],
        ),
      );
    }

    // No data
    if (state.stats == null || state.stats!.totalInstances == 0) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 70,
          title: AutoSizeText(
            'Statistik für ${state.session!.title}',
            style: context.textTheme.headlineLarge,
            maxLines: 2,
            textAlign: TextAlign.center,
            minFontSize: 14,
          ),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Text(
                    '''Noch keine Statistiken verfügbar, starte, indem du eine Lerneinheit beginnst!''',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = state.stats!;
    final session = state.session!;

    // Filter out any null instances for safety
    final allCompletedInstances =
        state.instances!.where((e) => e.completedAt != null).toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    final allNoneSkippedInstances =
        allCompletedInstances
            .where(
              (i) => i.status != SessionStatus.skipped,
            )
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    // Data available
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        title: AutoSizeText(
          'Statistik für ${state.session!.title}',
          style: context.textTheme.headlineLarge,
          maxLines: 2,
          textAlign: TextAlign.center,
          minFontSize: 14,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /// Goals and Task Progress
                      GoalTaskCompletionCard(
                        stats: stats,
                        pastInstances: allNoneSkippedInstances,
                        totalGoals: state.totalGoals!,
                        totalTasks: state.totalTasks!,
                      ),

                      const VerticalSpace(),

                      /// Focus time spent on last sessions
                      FocusTimeSpentCard(
                        stats: stats,
                        completedInstances: allCompletedInstances,
                        targetFocusMinutes: session.focusTimeMin.toDouble(),
                      ),

                      const VerticalSpace(),

                      // Shows average mood; or course of mood for
                      // repeating session
                      MoodCard(
                        stats: stats,
                        instances: allCompletedInstances,
                      ),

                      const VerticalSpace(),

                      // Only if the session was supposed
                      // to have a focus prompt
                      // Shows only the statistics of the
                      // current session performed
                      if (state.session!.hasFocusPrompt) ...[
                        // Shows how often what focus prompt has been clicked
                        FocusPromptCard(
                          allDoneInstances: allNoneSkippedInstances,
                          currentInstance: allCompletedInstances.first,
                          showGeneralStatsOnly: showGeneralStatsOnly,
                          focusChecks: allCompletedInstances.first.focusChecks,
                        ),
                        const VerticalSpace(),
                      ],

                      /// Progress so far (completed/skipped/missed)
                      ProgressCard(
                        stats: stats,
                        instances: state.allInstances,
                      ),

                      const VerticalSpace(),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: context.mediaQuery.size.width,
                child: CustomButton(
                  onPressed: () => showGeneralStatsOnly
                      ? Navigator.of(context).pop()
                      : Navigator.of(context).pushNamed(AppRoutes.home),
                  label: showGeneralStatsOnly
                      ? 'Zurück'
                      : 'Zurück zum Startbildschirm',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
