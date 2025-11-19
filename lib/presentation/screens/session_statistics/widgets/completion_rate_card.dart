import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

class CompletionRateCard extends StatelessWidget {
  const CompletionRateCard({required this.stats});

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
