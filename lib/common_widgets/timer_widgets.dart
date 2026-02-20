import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class PreviewBlock extends StatelessWidget {
  const PreviewBlock({
    required this.color,
    required this.label,
    required this.size,
    super.key,
  });

  final Color color;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          label,
          style: context.textTheme.labelSmall!.copyWith(
            color: context.colorScheme.onPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
