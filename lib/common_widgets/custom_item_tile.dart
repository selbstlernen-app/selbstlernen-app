import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomItemTile extends StatelessWidget {
  const CustomItemTile({
    super.key,
    required this.text,
    required this.isLargeGoal,
  });
  final String text;
  final bool isLargeGoal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          isLargeGoal
              ? const Icon(Icons.emoji_flags_rounded, size: 28)
              : const Icon(Icons.check_box_outline_blank_rounded, size: 28),

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
