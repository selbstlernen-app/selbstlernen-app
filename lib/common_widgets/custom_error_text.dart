import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomErrorText extends StatelessWidget {
  const CustomErrorText({super.key, required this.errorText});
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
      child: Text(
        errorText,
        style: context.textTheme.bodySmall!.copyWith(
          color: context.colorScheme.error,
          fontSize: 13.0,
        ),
      ),
    );
  }
}
