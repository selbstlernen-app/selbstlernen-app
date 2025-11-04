import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Text field used on multiple pages and screens
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.hasError = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool hasError;
  final Function? onChanged;
  final Function? onSubmitted;
  final Function? onTap;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (String value) => onChanged?.call(value),
      onSubmitted: (String value) => onSubmitted?.call(value),
      onTap: () => onTap?.call(),
      controller: controller,
      textInputAction: TextInputAction.go,
      readOnly: readOnly ?? false,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colorScheme.tertiary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? context.colorScheme.error : Colors.transparent,
          ),
        ),

        hintText: hintText,
        hintStyle: TextStyle(color: context.colorScheme.onTertiary),
      ),
    );
  }
}
