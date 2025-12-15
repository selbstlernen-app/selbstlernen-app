import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    required this.icon,
    required this.onPressed,
    required this.isActive,
    super.key,
    this.radius = 20,
    this.label,
    this.verticalPadding = 0,
  });

  final Icon icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final double radius;
  final String? label;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: label != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              )
            : const CircleBorder(),
        padding: label != null
            ? EdgeInsets.symmetric(
                vertical: verticalPadding ?? 16.0,
                horizontal: 12,
              )
            : EdgeInsets.all(radius * 0.4),
        backgroundColor: isActive
            ? context.colorScheme.primary
            : context.colorScheme.surface,
        foregroundColor: isActive
            ? context.colorScheme.onPrimary
            : context.colorScheme.onTertiary,
      ),
      child: label != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[icon, const SizedBox(width: 8), Text(label!)],
            )
          : icon,
    );
  }
}
