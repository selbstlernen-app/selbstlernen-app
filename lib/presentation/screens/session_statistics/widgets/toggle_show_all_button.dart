import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Button available on all charts to show complete data
class ToggleShowAllButton extends StatelessWidget {
  const ToggleShowAllButton({
    required this.showAll,
    required this.onToggle,
    required this.thresholdExceeded,
    super.key,
  });

  /// Whether full content is currently shown
  final bool showAll;

  /// Button should only be shown, when threshold met
  final bool thresholdExceeded;

  /// Called when button is pressed
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    if (!thresholdExceeded) return const SizedBox.shrink();

    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
        textStyle: context.textTheme.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colorScheme.onTertiary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      onPressed: onToggle,
      icon: Icon(showAll ? Icons.compress : Icons.expand),
      label: Text(showAll ? 'Weniger' : 'Alle anzeigen'),
    );
  }
}
