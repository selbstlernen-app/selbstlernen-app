import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomItemTile extends StatelessWidget {
  const CustomItemTile({
    required this.text,
    required this.isLargeGoal,
    this.iconSize = 28,
    super.key,
  });
  final String text;
  final bool isLargeGoal;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: <Widget>[
          if (isLargeGoal)
            Icon(
              Icons.emoji_flags_rounded,
              size: iconSize,
              color: context.colorScheme.primary,
            )
          else
            Icon(
              Icons.check_box_outline_blank_rounded,
              size: iconSize,
              color: context.colorScheme.primary,
            ),

          const HorizontalSpace(size: SpaceSize.small),

          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
