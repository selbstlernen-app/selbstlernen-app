import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/time_productivity/stats_line_chart.dart';

class TimeLearnedCard extends ConsumerWidget {
  const TimeLearnedCard({super.key, required this.instances});

  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Lernzeiten", style: context.textTheme.headlineMedium),
            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              "Zeiten, zu denen du dein Lernen beendet hast.",
              style: context.textTheme.bodySmall,
            ),
            const VerticalSpace(size: SpaceSize.small),

            // Line chart
            StatsLineChart(instances: instances),
          ],
        ),
      ),
    );
  }
}
