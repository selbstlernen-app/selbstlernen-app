import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.radius,
    required this.isActive,
    required this.onPressed,
    required this.icon,
  });
  final double radius;
  final bool isActive;
  final VoidCallback onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: isActive
          ? context.colorScheme.primary
          : context.colorScheme.tertiary,
      child: IconButton(
        icon: icon,
        color: isActive ? Colors.white : context.colorScheme.onTertiary,
        onPressed: onPressed,
      ),
    );
  }
}
