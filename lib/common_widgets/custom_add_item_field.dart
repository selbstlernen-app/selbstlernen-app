import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CustomAddItemField extends StatelessWidget {
  const CustomAddItemField({
    super.key,
    required this.onSubmitted,
    required this.onPressed,
    required this.controller,
    required this.hintText,
    this.hasError,
  });

  /// Function called when item is to be added
  final Function onSubmitted;

  /// The same function as onSubmitted usually, but has other type
  final VoidCallback onPressed;

  /// The controller for the text field
  final TextEditingController controller;

  /// The hinttext supposed to be displayed within the text field
  final String hintText;

  /// Indicates if error is shown or not
  final bool? hasError;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomTextField(
            onSubmitted: (_) => onSubmitted(),
            controller: controller,
            hintText: hintText,
            hasError: hasError ?? false,
          ),
        ),
        const HorizontalSpace(size: SpaceSize.small),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            foregroundColor: context.colorScheme.onPrimary,
            backgroundColor: context.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
