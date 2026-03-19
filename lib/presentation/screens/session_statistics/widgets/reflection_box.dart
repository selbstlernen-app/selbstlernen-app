import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// A info box that shows some information regarding the data displayed
class ReflectionBox extends StatelessWidget {
  const ReflectionBox({
    required this.color,
    required this.reflection,
    this.iconData,
    this.emoji,
    super.key,
  });

  /// Color of the box and text
  final Color color;

  /// Reflection text
  final String reflection;

  /// Optional icon displayed next to the reflection
  final IconData? iconData;

  /// Optional emoji displayed next to the reflection
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 1.5,
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (emoji != null)
            Text(
              emoji!,
              style: context.textTheme.bodyLarge!.copyWith(fontSize: 20),
            ),
          if (iconData != null)
            Icon(
              size: 20,
              iconData,
              color: color,
            ),
          const HorizontalSpace(
            size: SpaceSize.small,
          ),
          Expanded(
            child: Text(
              reflection,
              style: context.textTheme.bodySmall?.copyWith(
                color: color,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
