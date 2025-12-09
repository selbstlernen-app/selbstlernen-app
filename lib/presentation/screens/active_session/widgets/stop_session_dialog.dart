import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/show_custom_dialog.dart';

class StopSessionDialog {
  static Future<void> show({
    required BuildContext context,
    required int totalEdits,
    required bool isRepeating,
    required VoidCallback onStartTimer,
    required Future<void> Function() onDiscardAll,
    required Future<void> Function() onShowDetailedSelection,
  }) async {
    if (!isRepeating || totalEdits == 0) {
      // No edits or not repeating - go directly to reflection
      await onDiscardAll();
      return;
    }

    await showCustomDialog(
      context: context,
      title: 'Lerneinheit beenden',
      content: Text(
        '''Du hast $totalEdits ${totalEdits == 1 ? 'Ziel/Aufgabe' : 'Ziele und Aufgaben'}'''
        '''in dieser Lerneinheit bearbeitet, möchtest du die Bearbeitungen übernehmen?''',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      confirmLabel: 'Ja',
      cancelLabel: 'Nein',
      onCancel: onDiscardAll,
      onConfirm: onShowDetailedSelection,
    );
  }
}
