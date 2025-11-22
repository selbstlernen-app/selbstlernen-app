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
          Text(
            'Abgeschlossene Einheiten',
            style: context.textTheme.headlineSmall,
          ),
          const VerticalSpace(size: SpaceSize.medium),
          Column(
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  SizedBox(
                    height: 72,
                    width: 72,
                    child: CircularProgressIndicator(
                      value: stats.completionRate,
                      backgroundColor: AppPalette.grey.withValues(alpha: 0.4),
                      strokeWidth: 5,
                    ),
                  ),
                  Text("\n${(stats.completionRate * 100).toStringAsFixed(0)}%"),
                ],
              ),
              const HorizontalSpace(size: SpaceSize.medium),
              Text(
                '${stats.completedInstances} von ${stats.totalInstances} Einheiten abgeschlossen.',
                style: context.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('\nabgeschlossen', style: context.textTheme.bodySmall),
                  if (stats.skippedInstances > 0) ...<Widget>[
                    const VerticalSpace(size: SpaceSize.xsmall),
                    Text(
                      '${stats.skippedInstances} übersprungen',
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
