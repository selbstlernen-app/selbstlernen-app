import 'package:flutter/material.dart';
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        isLargeGoal
            ? Text("🏁", style: context.textTheme.headlineLarge)
            : Icon(
                Icons.check_box_outline_blank_rounded,
                size: 25,
                color: context.colorScheme.primary,
              ),

        Expanded(
          child: Text(
            text,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
