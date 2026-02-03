import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Class keeping all dialogs for the detail session screen
class SessionDialogs {
  static Future<void> showSkipSession(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return _show(
      context,
      title: 'Lerneinheit überspringen?',
      content:
          'Wenn du diese Einheit überspringst, wird diese als übersprungen markiert und muss nicht mehr durchgeführt werden.',
      onConfirm: onConfirm,
    );
  }

  static Future<void> showDeleteSession(
    BuildContext context, {
    required bool isRepeating,
    required VoidCallback onConfirm,
  }) {
    return _show(
      context,
      title: 'Lerneinheit löschen?',
      content:
          'Wenn du diese Einheit löschst, löschst du auch alle bisher durchgeführten Instanzen und Daten.\n'
          '${isRepeating ? 'Willst du diese und alle zukünftigen Einheiten löschen?' : 'Willst du diese Einheit wirklich löschen?'}',
      onConfirm: onConfirm,
    );
  }

  static Future<void> showArchive(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return _show(
      context,
      title: 'Lerneinheit archivieren?',
      content:
          'Wenn du diese Einheit archivierst, wirst du sie nicht länger bearbeiten oder durchführen können.',
      onConfirm: onConfirm,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: context.textTheme.headlineMedium),
        content: Text(content, style: context.textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }
}
