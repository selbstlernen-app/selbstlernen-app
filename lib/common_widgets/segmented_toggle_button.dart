import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';

/// Widget showing two buttons, between which user can switch modes
class SegmentedToggleButton extends StatelessWidget {
  const SegmentedToggleButton({
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftActive,
    required this.onLeftPressed,
    required this.onRightPressed,
    super.key,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftActive;
  final VoidCallback onLeftPressed;
  final VoidCallback onRightPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: CustomButton(
            onPressed: onLeftPressed,
            label: leftLabel,
            isActive: isLeftActive,
            borderLeft: true,
            verticalPadding: 8,
          ),
        ),
        Expanded(
          child: CustomButton(
            onPressed: onRightPressed,
            label: rightLabel,
            isActive: !isLeftActive,
            borderRight: true,
            verticalPadding: 8,
          ),
        ),
      ],
    );
  }
}
