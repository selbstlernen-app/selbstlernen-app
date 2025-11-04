import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        isLargeGoal
            ? Text("🏁", style: context.textTheme.headlineLarge)
            : Icon(
                Icons.check_box_outline_blank_rounded,
                size: 24,
                color: context.colorScheme.primary,
              ),

        const HorizontalSpace(size: SpaceSize.small),

        Text(
          text,
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
