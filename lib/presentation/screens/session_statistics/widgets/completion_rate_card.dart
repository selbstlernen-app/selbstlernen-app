import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/session_status_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';

class CompletionRateCard extends StatelessWidget {
  const CompletionRateCard({
    required this.stats,
    required this.instances,
    super.key,
  });

  final SessionStatistics stats;
  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fortschritt', style: context.textTheme.headlineMedium),

              IconButton(
                color: AppPalette.grey.withValues(alpha: 0.5),
                icon: const Icon(Icons.history_rounded),
                onPressed: () => showHistoryBottomSheet(
                  context,
                  instances,
                  'Einheiten-Fortschritt',
                  (instance) => getSubtitle(instance.status),
                ),
              ),
            ],
          ),
          const VerticalSpace(size: SpaceSize.small),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  SizedBox(
                    height: 120,
                    width: 140,
                    child: PieChart(
                      // Completed sessions
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 45,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: getColor(SessionStatus.completed),
                            value: stats.completionRate * 100,
                            title: '',
                            radius: 16,
                          ),
                          // Missed sessions
                          PieChartSectionData(
                            color: getColor(SessionStatus.missed),
                            value: stats.missRate * 100,
                            title: '',
                            radius: 16,
                          ),
                          // Skipped sessions
                          PieChartSectionData(
                            color: getColor(SessionStatus.skipped),
                            value: stats.skipRate * 100,
                            title: '',
                            radius: 16,
                          ),

                          // Remaining/empty space
                          if (stats.completionRate +
                                  stats.skipRate +
                                  stats.missRate <
                              1)
                            PieChartSectionData(
                              color: AppPalette.grey.withValues(alpha: 0.2),
                              value:
                                  (1 -
                                      stats.completionRate -
                                      stats.skipRate -
                                      stats.missRate) *
                                  100,
                              title: '',
                              radius: 16,
                            ),
                        ],
                      ),
                    ),
                  ),

                  Text(
                    '${(stats.combinedRate * 100).toStringAsFixed(1)}%',
                    style: context.textTheme.headlineSmall,
                  ),
                ],
              ),

              const HorizontalSpace(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    stats.totalInstances == 1
                        ? 'Abgeschlossen'
                        : '''${stats.completedInstances + stats.skippedInstances + stats.missedInstances} '''
                              '''von ${stats.totalInstances} Einheiten\nabgeschlossen''',
                    style: context.textTheme.bodyMedium,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 5,
                        width: 5,
                        decoration: BoxDecoration(
                          color: getColor(SessionStatus.completed),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const HorizontalSpace(size: SpaceSize.small),
                      Text(
                        '${stats.completedInstances} durchgeführt',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  if (stats.missedInstances > 0) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.xsmall),
                    Row(
                      children: <Widget>[
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            color: getColor(SessionStatus.missed),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const HorizontalSpace(size: SpaceSize.small),
                        Text(
                          '${stats.missedInstances} verpasst',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],

                  if (stats.skippedInstances > 0) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.xsmall),

                    Row(
                      children: <Widget>[
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            color: getColor(SessionStatus.skipped),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const HorizontalSpace(size: SpaceSize.small),
                        Text(
                          '${stats.skippedInstances} übersprungen',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],

                  const VerticalSpace(size: SpaceSize.xsmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 5,
                        width: 5,
                        decoration: BoxDecoration(
                          color: AppPalette.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const HorizontalSpace(size: SpaceSize.small),
                      Text(
                        '${stats.openInstances} Noch offen',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
