import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/completion_rate_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/time_productivity/spent_time_card.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/time_productivity/time_learned_card.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_view_model.dart';

class SessionStatisticsScreen extends ConsumerWidget {
  const SessionStatisticsScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionStatisticsState state = ref.watch(
      sessionStatisticsViewModelProvider(sessionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Session Statistiken für\n${state.session!.title}'),
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SessionStatisticsState state,
  ) {
    if (state.isLoading && state.stats == null && state.instances == null) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Fehler: ${state.error}'),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    // No data
    if (state.stats == null) {
      return const Center(child: Text('Keine Statistiken verfügbar'));
    }

    final SessionStatistics stats = state.stats!;
    final List<SessionInstanceModel> instances = state.instances!;

    // Empty state
    if (stats.totalInstances == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Noch keine Statistiken', style: context.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Starte deine erste Session!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
              label: "Zurück zum Startbildschirm",
            ),
          ],
        ),
      );
    }

    // Data available
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /// Productivity
          /// Time spent; per weekday visualizing focus time
          /// Shows total sessions, avg focus time and bar chart
          SpentTimeCard(
            stats: stats,
            weekdayMinutes: state.weekdayMinutes!,
            plannedFocusMinutesPerWeekday: plannedFocusMinutesPerWeekday(
              state.session!,
            ),
          ),

          /// Consistency & Habit Formation;
          ///   Completion rate (completed/skipped)
          CompletionRateCard(stats: stats),

          const VerticalSpace(size: SpaceSize.medium),

          /// Shows the time sessions were completed (Tendency evening/morning/etc.)
          if (state.session?.isRepeating == true) ...<Widget>[
            TimeLearnedCard(instances: instances),
            const VerticalSpace(size: SpaceSize.medium),
          ],

          /// Goals and Task Progress
          ///   Goals/Tasks completed per session
          ///   Goal completion trend (weekly/monthly)

          /// Reflection/Well-being
          ///   Mood trend over time
          const VerticalSpace(size: SpaceSize.xlarge),

          //

          // Instance history
          // InstanceHistory(
          //   sessionId: sessionId,
          //   instances: state.instances ?? [],
          // ),
          CustomButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
            label: "Zurück zum Startbildschirm",
          ),
        ],
      ),
    );
  }

  List<int> plannedFocusMinutesPerWeekday(SessionModel session) {
    // Total of one block focus time
    final int plannedMinutes = session.focusTimeMin * session.focusPhases;

    // If non-repeating session, fill with 0
    if (!session.isRepeating) {
      return List<int>.generate(7, (int i) => plannedMinutes);
    }

    // If repeating, fill for each selected day
    return List<int>.generate(
      7,
      (int i) => session.selectedDays.contains(i) ? plannedMinutes : 0,
    );
  }
}
