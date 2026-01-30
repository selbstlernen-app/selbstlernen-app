import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/custom_filter_chip.dart';
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
    final isLoading = ref.watch(
      statisticsViewModelProvider.select((s) => s.isLoading),
    );
    final error = ref.watch(statisticsViewModelProvider.select((s) => s.error));

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 64, color: AppPalette.rose),
            const VerticalSpace(),
            Text('Fehler: $error'),
          ],
        ),
      );
    }
    if (isLoading) return const LoadingIndicator();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              centerTitle: true,
              title: Text(
                'Gesamt-Statistik',
                style: context.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              automaticallyImplyLeading: false,
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Calendar
                    LearnCalendar(),

                    VerticalSpace(),

                    // Stats row
                    StatsSection(),

                    VerticalSpace(),
                    // Filter buttons
                    FilterRow(),
                  ],
                ),
              ),
            ),

            const SliverSessionList(),
          ],
        ),
      ),
    );
  }
}

class SliverSessionList extends ConsumerWidget {
  const SliverSessionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(
      statisticsViewModelProvider.select((s) => s.filter),
    );

    final sessions = ref.watch(
      statisticsViewModelProvider.select(
        (s) => filter == StatisticsFilter.running
            ? s.activeSessions
            : s.archivedSessions,
      ),
    );

    if (sessions.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text('Keine Lerneinheiten gefunden'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final session = sessions[index];
            return ArchivedSessionTile(
              key: ValueKey(session.id),
              session: session,
            );
          },
          childCount: sessions.length,
        ),
      ),
    );
  }
}

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsViewModelProvider.select((s) => s.stats));

    if (stats == null || stats.totalInstances == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: buildStatColumn(
            context,
            'Fokuszeit\ninsgesamt',
            TimeUtils.formatBarChartTime(
              stats.totalFocusMinutes.toDouble(),
            ),
          ),
        ),

        Expanded(
          child: buildStatColumn(
            context,
            'Durchgeführte Einheiten',
            stats.totalInstances.toString(),
          ),
        ),
      ],
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

class FilterRow extends ConsumerWidget {
  const FilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(
      statisticsViewModelProvider.select((s) => s.filter),
    );
    final hasActive = ref.watch(
      statisticsViewModelProvider.select((s) => s.activeSessions.isNotEmpty),
    );
    final hasArchived = ref.watch(
      statisticsViewModelProvider.select((s) => s.archivedSessions.isNotEmpty),
    );

    return Row(
      children: [
        if (hasActive)
          CustomFilterChip(
            label: 'Aktuell',
            isActive: filter == StatisticsFilter.running,
            onPressed: () => ref
                .read(statisticsViewModelProvider.notifier)
                .setFilter(StatisticsFilter.running),
          ),

        const HorizontalSpace(
          size: SpaceSize.xsmall,
        ),

        if (hasArchived)
          CustomFilterChip(
            label: 'Archiviert',
            isActive: filter == StatisticsFilter.archived,
            onPressed: () => ref
                .read(statisticsViewModelProvider.notifier)
                .setFilter(StatisticsFilter.archived),
          ),
      ],
    );
  }
}
