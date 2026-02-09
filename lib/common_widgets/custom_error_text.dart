import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomErrorText extends StatelessWidget {
  const CustomErrorText({required this.errorText, super.key});
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Text(
        errorText,
        style: context.textTheme.bodySmall!.copyWith(
          color: context.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
