import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_prompt_chart.dart';

class FocusPromptCard extends StatelessWidget {
  const FocusPromptCard({
    required this.focusChecks,
    required this.currentInstance,
    super.key,
  });

  final SessionInstanceModel currentInstance;
  final List<FocusCheck> focusChecks;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fokus-Verlauf',
            style: context.textTheme.headlineMedium,
          ),
          const VerticalSpace(
            size: SpaceSize.small,
          ),

          FocusLevelChart(instance: currentInstance),
        ],
      ),
    );
  }
}
