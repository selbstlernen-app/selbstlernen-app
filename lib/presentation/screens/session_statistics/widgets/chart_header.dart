import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';

class ChartHeader extends StatelessWidget {
  const ChartHeader({
    required this.title,
    required this.instances,
    required this.getAttributeValue,
    super.key,
  });

  /// The title of the chart
  final String title;

  /// List of all instances to be displayed when calling the history log
  final List<SessionInstanceModel> instances;

  /// The function for the history log
  final String Function(SessionInstanceModel) getAttributeValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.textTheme.headlineMedium),
        IconButton(
          color: AppPalette.grey.withValues(alpha: 0.5),
          icon: const Icon(Icons.history_rounded),
          onPressed: () => showHistoryBottomSheet(
            context,
            instances,
            title,
            getAttributeValue,
          ),
        ),
      ],
    );
  }
}
