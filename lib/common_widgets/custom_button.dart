import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Main button used on all pages customized to fit different stylings
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    required this.label,
    super.key,
    this.isActive = true,
    this.verticalPadding,
    this.borderRadius,
    this.borderLeft,
    this.borderRight,
  });

  final VoidCallback onPressed;
  final String label;
  final bool isActive;
  final double? verticalPadding;
  final double? borderRadius;
  final bool? borderLeft;
  final bool? borderRight;

  BorderRadius _switchRadius() {
    if (borderLeft ?? false) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(10),
        topLeft: Radius.circular(10),
      );
    }
    if (borderRight ?? false) {
      return const BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      );
    }
    return BorderRadius.circular(borderRadius ?? 30.0);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = context.colorScheme.primary;
    final activeAccentColor = context.colorScheme.onPrimary;
    final inactiveColor = context.colorScheme.tertiaryContainer;
    final inactiveAccentColor = context.colorScheme.onTertiary;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? activeColor : inactiveColor,
        shape: RoundedRectangleBorder(borderRadius: _switchRadius()),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding ?? 16.0,
          horizontal: 12,
        ),
      ),

      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isActive ? activeAccentColor : inactiveAccentColor,
        ),
      ),
    );
  }
}
