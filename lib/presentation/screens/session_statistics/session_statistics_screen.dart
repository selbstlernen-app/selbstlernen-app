import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
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
            Icon(Icons.bar_chart, size: 64, color: AppPalette.grey),
            const VerticalSpace(size: SpaceSize.medium),
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
            const VerticalSpace(size: SpaceSize.medium),
            CustomButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
              label: "Zurück zum Startbildschirm",
            ),
          ],
        ),
      );
    }

    // Data available
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Statistik für\n${state.session!.title}',
            style: context.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// Productivity
              /// Shows how much time spent on which weekday
              /// vs. how much was expected (Focus-time only)
              SpentTimeCard(
                stats: stats,
                weekdayMinutes: state.weekdayMinutes!,
                plannedFocusMinutesPerWeekday: plannedFocusMinutesPerWeekday(
                  state.session!,
                  !state.session!.isRepeating ? state.instances!.first : null,
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
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.home),
                label: "Zurück zum Startbildschirm",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns an array for each day with the planned minutes
  /// For a repeating session this means the selected days
  /// For a non-repeating session, this solely means the date on which the session was conducted on
  List<int> plannedFocusMinutesPerWeekday(
    SessionModel session,
    SessionInstanceModel? instance,
  ) {
    // Total of one block focus time
    final int plannedMinutes = session.focusTimeMin * session.focusPhases;

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
}
