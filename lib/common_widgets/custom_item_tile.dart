import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomItemTile extends StatelessWidget {
  const CustomItemTile({
    required this.text,
    required this.isLargeGoal,
    this.iconSize = 28,
    this.hasDelete = false,
    this.onDelete,
    super.key,
  });
  final String text;
  final bool isLargeGoal;
  final double? iconSize;
  final bool hasDelete;
  final VoidCallback? onDelete;

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

          if (hasDelete)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_forever_rounded),
            ),
        ],
      ),
    );
  }
}
