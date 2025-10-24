import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Main button used on all pages customized to fit different stylings
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
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
    if (borderLeft == true) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(10.0),
        topLeft: Radius.circular(10.0),
      );
    }
    if (borderRight == true) {
      return const BorderRadius.only(
        topRight: Radius.circular(10.0),
        bottomRight: Radius.circular(10.0),
      );
    }
    return BorderRadius.circular(borderRadius ?? 30.0);
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = context.colorScheme.primary;
    Color activeAccentColor = context.colorScheme.onPrimary;
    Color inactiveColor = context.colorScheme.tertiaryContainer;
    Color inactiveAccentColor = context.colorScheme.onTertiary;

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
      child: AutoSizeText(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isActive ? activeAccentColor : inactiveAccentColor,
        ),
      ),
    );
  }
}
