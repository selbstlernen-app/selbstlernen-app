import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/completion_rate_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_time_spent/focus_time_spent_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/goal_task_completion/goal_task_completion_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/mood/mood_card.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_view_model.dart';

class SessionStatisticsScreen extends ConsumerWidget {
  const SessionStatisticsScreen({required this.sessionId, super.key});

  final int sessionId;

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
    if (state.stats == null) {
      return const Center(
        child: Text(
          '''Noch keine Statistiken verfügbar, beginne, indem du eine Lerneinheit anlegst''',
        ),
      );
    }

    final stats = state.stats!;
    final instances = state.instances!;
    final session = state.session!;

    final currentInstance = instances
        .where((i) => i.completedAt != null)
        .sorted(
          (a, b) => b.completedAt!.compareTo(a.completedAt!),
        ) // Sort descending; most current one on top
        .toList()
        .first;

    // Empty state
    if (stats.totalInstances == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.bar_chart, size: 64, color: AppPalette.grey),
            const VerticalSpace(),
            Text(
              'Noch keine Statistiken',
              style: context.textTheme.headlineMedium,
            ),
            const VerticalSpace(size: SpaceSize.small),
            Text(
              'Starte deine erste Session!',
              style: context.textTheme.bodySmall!.copyWith(
                color: AppPalette.grey,
              ),
            ),
            const VerticalSpace(),
            CustomButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
              label: 'Zurück zum Startbildschirm',
            ),
          ],
        ),
      );
    }

    // Data available
    return Scaffold(
      backgroundColor: Color.lerp(
        context.colorScheme.secondary,
        Colors.white,
        0.3,
      ),
      appBar: AppBar(
        backgroundColor: Color.lerp(
          context.colorScheme.secondary,
          Colors.white,
          0.3,
        ),
        centerTitle: true,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AutoSizeText(
                'Statistik für ${state.session!.title}',
                style: context.textTheme.headlineLarge,
                maxLines: 2,
                textAlign: TextAlign.center,
                minFontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        pastInstances: instances,
                        currentInstance: currentInstance,
                        totalGoals: state.goals!.length,
                        totalTasks: state.tasks!.length,
                      ),

                      const VerticalSpace(),

                      /// Completion rate (completed/skipped)
                      CompletionRateCard(
                        stats: stats,
                        instances: [...instances, ...missedInstances(state)],
                      ),

                      const VerticalSpace(),

                      /// Focus time spent on last sessions
                      FocusTimeSpentCard(
                        stats: stats,
                        pastInstances: instances,
                        targetFocusMinutes: session.focusTimeMin.toDouble(),
                      ),

                      const VerticalSpace(),

                      // Shows average mood; or course of mood for
                      // repeating session
                      MoodCard(stats: stats, instances: instances),

                      const VerticalSpace(),

                      // Only if the session was supposed
                      // to have a focus prompt
                      // Shows only the statistics of the
                      // current session performed
                      if (state.session!.hasFocusPrompt) ...[
                        // Shows how often what focus prompt has been clicked
                        FocusPromptCard(
                          focusChecks: currentInstance.focusChecks,
                        ),
                        const VerticalSpace(),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: context.mediaQuery.size.width,
                child: CustomButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.home),
                  label: 'Zurück zum Startbildschirm',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns an array for each day with the planned minutes
  /// For a repeating session this means the selected days
  /// For a non-repeating session, this solely means the date on which
  /// the session was conducted on
  List<int> plannedFocusMinutesPerWeekday(
    SessionModel session,
    SessionInstanceModel? instance,
  ) {
    // Total of one block focus time
    final plannedMinutes = session.focusTimeMin;

    // If non-repeating session, fill all with zero unless the scheduled day
    if (!session.isRepeating && instance != null) {
      return List<int>.generate(
        7,
        (int i) => (instance.scheduledAt.weekday - 1 == i) ? plannedMinutes : 0,
      );
    }

    // If repeating, fill for each selected day
    return List<int>.generate(
      7,
      (int i) => session.selectedDays.contains(i) ? plannedMinutes : 0,
    );
  }

  List<SessionInstanceModel> missedInstances(SessionStatisticsState state) {
    final session = state.session;
    final real = state.instances ?? [];

    if (session == null || !session.isRepeating) return [];

    // Index existing instances by their date
    final instanceByDate = {
      for (final inst in real)
        if (inst.completedAt != null)
          DateTime(
            inst.completedAt!.year,
            inst.completedAt!.month,
            inst.completedAt!.day,
          ): inst,
    };

    final missed = <SessionInstanceModel>[];

    for (final date in generateScheduledDates(
      session.startDate!,
      session.selectedDays,
    )) {
      if (!instanceByDate.containsKey(date)) {
        // Create a fake instance for display purposes
        missed.add(
          SessionInstanceModel(
            sessionId: state.session!.id!,
            id: 'missed-${date.toIso8601String()}',
            completedAt: date,
            scheduledAt: date,
            status: SessionStatus.missed,
          ),
        );
      }
    }

    return missed;
  }

  Iterable<DateTime> generateScheduledDates(
    DateTime start,
    List<int> selectedWeekdays,
  ) sync* {
    final today = DateTime.now();
    final normalizedEnd = DateTime(today.year, today.month, today.day);

    var current = DateTime(start.year, start.month, start.day);

    while (!current.isAfter(normalizedEnd)) {
      if (selectedWeekdays.contains(current.weekday - 1)) {
        yield current;
      }
      current = current.add(const Duration(days: 1));
    }
  }
}
