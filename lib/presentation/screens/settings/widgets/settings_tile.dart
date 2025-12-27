import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onToggle,
    super.key,
    this.expandedChild,
  });

  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback onToggle;

  /// Optional extra UI shown when enabled
  final Widget? expandedChild;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                title,
                style: context.textTheme.headlineSmall,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: context.textTheme.bodySmall,
            ),
            trailing: Switch(
              value: isEnabled,
              onChanged: (_) => onToggle(),
            ),
            onTap: onToggle,
          ),

          // Show an expansion child (e.g. given in notification settings)
          if (isEnabled && expandedChild != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: expandedChild,
            ),
        ],
      ),
    );
  }
}
