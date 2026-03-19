import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class EmptyChart extends StatelessWidget {
  const EmptyChart({
    required this.iconData,
    required this.infoTitle,
    required this.infoSubtitle,
    super.key,
  });
  final IconData iconData;
  final String infoTitle;
  final String infoSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(size: SpaceSize.small),
        Icon(
          iconData,
          size: 40,
          color: AppPalette.grey.withValues(alpha: 0.3),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          infoTitle,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          infoSubtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppPalette.grey,
          ),
        ),
      ],
    );
  }
}
