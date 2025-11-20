import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/spent_time_card.dart';
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
      appBar: AppBar(title: const Text('Session Statistiken')),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SessionStatisticsState state,
  ) {
    if (state.isLoading && state.stats == null) {
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
          // Stats cards
          SpentTimeCard(stats: stats, weekdayMinutes: state.weekdayMinutes!),

          const SizedBox(height: 16),

          // TODO: Heatmap for repeating sessions
          // if (state.session?.isRepeating == true) ...<Widget>[
          // HeatmapCard(instances: state.instances!),
          // const SizedBox(height: 16),
          // ],

          // Instance history
          // InstanceHistory(
          //   sessionId: sessionId,
          //   instances: state.instances ?? [],
          // ),

          // TODO: Average mood
          // if (stats.averageMood != null)
          //   AverageMoodCard(
          //     mood: ref
          //         .read(sessionStatisticsViewModelProvider(sessionId).notifier)
          //         .getAverageMoodForLastMonth(),
          //   ),
          CustomButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
            label: "Zurück zum Startbildschirm",
          ),
        ],
      ),
    );
  }
}
