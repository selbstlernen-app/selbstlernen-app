import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Text field used on multiple pages and screens
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    super.key,
    this.hintText,
    this.hasError = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly,
    this.maxLines,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool? readOnly;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      controller: controller,
      textInputAction: TextInputAction.go,
      readOnly: readOnly ?? false,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colorScheme.tertiary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError
                ? context.colorScheme.error
                : context.colorScheme.tertiary,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: context.colorScheme.onTertiary),
      ),
    );
  }
}
