import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Central class for all dialogs of the detail session screen
class InfoDialogs {
  static Future<void> showLearningStrategyInfo(
    BuildContext context,
  ) {
    return _show(
      context,
      title: 'Lernstrategien',
      content: '''
Wenn du lernst, verwendest du meistens bestimmte Strategien, wie etwa das Wiederholen von Karteikarten.\nSetzte dich explizit mit deinen bisherigen Strategien auseinander, und wähle eine, mit der du näher an deine Ziele gelangst.''',
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: context.textTheme.headlineMedium),
        content: Text(content, style: context.textTheme.bodyLarge),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}
