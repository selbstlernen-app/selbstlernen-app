import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/card_layout.dart';

class CompletionRateCard extends StatelessWidget {
  const CompletionRateCard({super.key, required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Abschlussrate', style: context.textTheme.headlineSmall),
          const VerticalSpace(size: SpaceSize.small),
          Row(
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  SizedBox(
                    height: 55,
                    width: 55,
                    child: CircularProgressIndicator(
                      value: stats.completionRate,
                      backgroundColor: AppPalette.grey.withValues(alpha: 0.2),
                      strokeWidth: 5,
                    ),
                  ),
                  Text(
                    "${(stats.completionRate * 100).toStringAsFixed(0)}%",
                    style: context.textTheme.headlineSmall,
                  ),
                ],
              ),

              const HorizontalSpace(size: SpaceSize.medium),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    stats.totalInstances == 1
                        ? 'Abgeschlossen'
                        : "${stats.completedInstances} von ${stats.totalInstances} Einheiten\nabgeschlossen.",
                    style: context.textTheme.bodyMedium,
                  ),

                  if (stats.skippedInstances > 0) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.small),
                    Text(
                      '${stats.skippedInstances} übersprungen.',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
