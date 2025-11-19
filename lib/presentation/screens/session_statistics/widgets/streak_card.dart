import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.local_fire_department,
                color: AppPalette.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text('Streak', style: context.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: <Widget>[
              Expanded(
                child: _StreakMetric(
                  label: 'Aktuelle Serie',
                  value: stats.currentStreak,
                  icon: Icons.whatshot,
                  color: AppPalette.orange,
                  isActive: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StreakMetric(
                  label: 'Längste Serie',
                  value: stats.longestStreak,
                  icon: Icons.military_tech,
                  color: AppPalette.orange,
                  isActive: false,
                ),
              ),
            ],
          ),

          if (stats.currentStreak > 0) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('🔥', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Du bist ${stats.currentStreak} Tage am Ball!',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppPalette.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(16),
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
