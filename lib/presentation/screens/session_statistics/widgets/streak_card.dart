import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/card_layout.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Aktive Tage', style: context.textTheme.headlineSmall),
          const VerticalSpace(size: SpaceSize.small),
          Row(
            children: <Widget>[
              _StreakMetric(
                label: 'Aktuelle Serie',
                value: stats.currentStreak,
                icon: Icons.whatshot,
                color: AppPalette.orange,
                isActive: true,
              ),

              _StreakMetric(
                label: 'Längste Serie',
                value: stats.longestStreak,
                icon: Icons.military_tech,
                color: AppPalette.orange,
                isActive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakMetric extends StatelessWidget {
  const _StreakMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isActive,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: color, width: 2) : null,
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: context.textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
