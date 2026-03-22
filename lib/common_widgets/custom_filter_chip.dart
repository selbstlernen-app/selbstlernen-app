import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Filter chip used for filtering out sessions;
/// used on home and general stats screen
class CustomFilterChip extends StatelessWidget {
  const CustomFilterChip({
    required this.isActive,
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // Animate background color
          color: isActive
              ? context.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          // Animate border color
          border: Border.all(
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.onSurface.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
