import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomItemTile extends StatelessWidget {
  const CustomItemTile({
    required this.text,
    required this.isLargeGoal,
    super.key,
  });
  final String text;
  final bool isLargeGoal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: <Widget>[
          if (isLargeGoal)
            const Icon(Icons.emoji_flags_rounded, size: 28)
          else
            const Icon(Icons.check_box_outline_blank_rounded, size: 28),

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
