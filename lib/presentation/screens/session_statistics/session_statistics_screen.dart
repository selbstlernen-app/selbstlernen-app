import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/providers.dart';

class SessionStatisticsScreen extends ConsumerWidget {
  const SessionStatisticsScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Statistiken')),
      body: FutureBuilder<SessionStatistics>(
        future: ref.read(getSessionStatisticsUseCaseProvider).call(sessionId),
        builder:
            (BuildContext context, AsyncSnapshot<SessionStatistics> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final SessionStatistics stats = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Completion Rate Card
                    _CompletionRateCard(stats: stats),

                    const SizedBox(height: 16),

                    // Time Investment Card
                    // _TimeInvestmentCard(stats: stats),
                    const SizedBox(height: 16),

                    // Productivity Card
                    // _ProductivityCard(stats: stats),
                    const SizedBox(height: 16),

                    // Streaks Card
                    // if (stats.currentStreak > 0) _StreaksCard(stats: stats),
                    const SizedBox(height: 16),

                    // Mood Card
                    // if (stats.averageMood != null) _MoodCard(stats: stats),
                    const SizedBox(height: 16),

                    // Instance History
                    // _InstanceHistorySection(sessionId: sessionId),
                    CustomButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.home),
                      label: "Zurück zum Startbildschirm",
                    ),
                  ],
                ),
              );
            },
      ),
    );
  }
}

// Example stat card
class _CompletionRateCard extends StatelessWidget {
  const _CompletionRateCard({required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Abschlussrate', style: context.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: CircularProgressIndicator(
                    value: stats.completionRate,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                        style: context.textTheme.headlineMedium,
                      ),
                      Text(
                        '${stats.completedInstances} von ${stats.totalInstances} abgeschlossen',
                        style: context.textTheme.bodyMedium,
                      ),
                      if (stats.skippedInstances > 0)
                        Text(
                          '${stats.skippedInstances} übersprungen',
                          style: context.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
