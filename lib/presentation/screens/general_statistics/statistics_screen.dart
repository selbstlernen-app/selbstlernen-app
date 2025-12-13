import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/presentation/screens/general_statistics/widgets/archived_session_tile.dart';
import 'package:srl_app/presentation/screens/general_statistics/widgets/learn_calendar.dart';
import 'package:srl_app/presentation/view_models/general_statistics/statistics_state.dart';
import 'package:srl_app/presentation/view_models/general_statistics/statistics_view_model.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsViewModelProvider);

    if (state.isLoading &&
        state.stats == null &&
        state.enrichedInstances == null) {
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
      return const Center(
        child: Text(
          '''Noch keine Statistiken verfügbar, beginne, indem du eine Lerneinheit anlegst''',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Gesamt-Statistik',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineLarge,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LearnCalendar(enrichedInstances: state.enrichedInstances!),

            const VerticalSpace(),

            if (state.stats!.totalInstances > 0)
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: buildStatColumn(
                        context,
                        'Fokuszeit\ninsgesamt',
                        TimeUtils.formatBarChartTime(
                          state.stats!.totalFocusMinutes.toDouble(),
                        ),
                      ),
                    ),

                    Expanded(
                      child: buildStatColumn(
                        context,
                        'Durchgeführte Einheiten',
                        state.stats!.totalInstances.toString(),
                      ),
                    ),
                  ],
                ),
              ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),
            // Filter buttons
            Row(
              children: [
                CustomButton(
                  verticalPadding: 4,
                  borderRadius: 10,
                  isActive: state.filter == StatisticsFilter.running,
                  onPressed: () => ref
                      .read(statisticsViewModelProvider.notifier)
                      .setFilter(
                        StatisticsFilter.running,
                      ),
                  label: 'Aktuell',
                ),
                const HorizontalSpace(
                  size: SpaceSize.small,
                ),
                CustomButton(
                  verticalPadding: 4,
                  borderRadius: 10,
                  isActive: state.filter == StatisticsFilter.archived,
                  onPressed: () => ref
                      .read(statisticsViewModelProvider.notifier)
                      .setFilter(StatisticsFilter.archived),
                  label: 'Archiviert',
                ),
              ],
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            if (state.activeOrArchivedSessions!.isNotEmpty &&
                state.filter == StatisticsFilter.running)
              ...state.activeSessions.map(
                (e) => ArchivedSessionTile(session: e),
              ),

            if (state.activeOrArchivedSessions!.isNotEmpty &&
                state.filter == StatisticsFilter.archived)
              ...state.archivedSessions.map(
                (e) => ArchivedSessionTile(session: e),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildStatColumn(BuildContext context, String label, String value) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppPalette.grey,
            ),
          ),
          const VerticalSpace(
            size: SpaceSize.small,
          ),
          Text(
            value,
            style: context.textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
