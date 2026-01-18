import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

Widget buildSection({
  required String title,
  required Widget child,
  required BuildContext context,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: context.textTheme.headlineMedium),

      const VerticalSpace(),

      child,
    ],
  );
}
