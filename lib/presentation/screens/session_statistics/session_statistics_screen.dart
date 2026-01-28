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
    if (state.isLoading && state.instances == null) {
      return const LoadingIndicator();
    }

    // Error
    if (state.error != null) {
      return Scaffold(body: Center(child: Text('Fehler: ${state.error}')));
    }

    final instances = state.instances ?? [];

    // Only include instances that are actually done or skipped
    final allCompletedInstances =
        instances
            .where(
              (e) =>
                  e.status == SessionStatus.completed ||
                  e.status == SessionStatus.skipped,
            )
            .toList()
          ..sort(
            (a, b) => (b.completedAt ?? DateTime.now()).compareTo(
              a.completedAt ?? DateTime.now(),
            ),
          );

    final noneSkipped = allCompletedInstances
        .where((i) => i.status != SessionStatus.skipped)
        .toList();

    if (allCompletedInstances.isEmpty) {
      return _buildEmptyState(context, state.session?.title ?? 'Session');
    }

    // Current/Latest instance
    final latestInstance = allCompletedInstances.first;

    // Data available
    return Scaffold(
      appBar: _buildAppBar(context, state.session?.title ?? ''),
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
                        stats: state.stats!,
                        pastInstances: noneSkipped,
                        totalGoals: state.totalGoals ?? 0,
                        totalTasks: state.totalTasks ?? 0,
                      ),

                      const VerticalSpace(),

                      /// Focus time spent on last sessions
                      FocusTimeSpentCard(
                        stats: state.stats!,
                        completedInstances: allCompletedInstances,
                        targetFocusMinutes: state.session!.focusTimeMin
                            .toDouble(),
                      ),

                      const VerticalSpace(),

                      // Shows average mood; or course of mood for
                      // repeating session
                      MoodCard(
                        stats: state.stats!,
                        instances: allCompletedInstances,
                      ),

                      const VerticalSpace(),

                      // Only when prompter activated during session
                      if (state.session!.hasFocusPrompt &&
                          noneSkipped.isNotEmpty) ...[
                        FocusPromptCard(
                          allDoneInstances: noneSkipped,
                          currentInstance: latestInstance,
                          showGeneralStatsOnly: showGeneralStatsOnly,
                          focusChecks: latestInstance.focusChecks,
                        ),
                        const VerticalSpace(),
                      ],

                      /// Progress so far (completed/skipped/missed)
                      ProgressCard(
                        stats: state.stats!,
                        instances: state.allInstances,
                      ),

                      const VerticalSpace(),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
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

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
      centerTitle: true,
      toolbarHeight: 70,
      title: AutoSizeText(
        'Statistik für $title',
        style: context.textTheme.headlineLarge,
        maxLines: 2,
        textAlign: TextAlign.center,
        minFontSize: 14,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String sessionTitle) {
    return Scaffold(
      appBar: _buildAppBar(context, sessionTitle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 80,
                color: context.colorScheme.primary.withValues(alpha: 0.2),
              ),
              const VerticalSpace(size: SpaceSize.large),
              Text(
                'Noch keine Daten verfügbar',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const VerticalSpace(size: SpaceSize.small),
              Text(
                'Schließe deine erste Einheit ab, um detaillierte Statistiken und Analysen zu sehen.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
