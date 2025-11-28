import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class TimeBreakdownItem extends StatelessWidget {
  const TimeBreakdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, color: color, size: 32),
            const HorizontalSpace(size: SpaceSize.small),
            Text(
              label,
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(value, style: context.textTheme.bodyLarge?.copyWith(color: color)),
      ],
    );
  }
}
