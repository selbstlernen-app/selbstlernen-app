import 'package:flutter/material.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

/// Class keeping all dialogs for the detail session screen
class SessionDialogs {
  static Future<void> showSkipSession(
    BuildContext context, {
    required Future<void> Function() onConfirm,
  }) {
    return _show(
      context,
      title: 'Lerneinheit überspringen?',
      content:
          '''Wenn eine Einheit übersprungen wird, musst du diese für den Tag nicht mehr durchgeführen.''',
      onConfirm: onConfirm,
      successMessage: 'Einheit übersprungen',
      shouldNavigateHome: false,
    );
  }

  static Future<void> showDeleteSession(
    BuildContext context, {
    required bool shouldNavigateHome,
    required bool isRepeating,
    required Future<void> Function() onConfirm,
  }) {
    return _show(
      context,
      title: 'Lerneinheit löschen?',
      content:
          '''Alle jemals aufgenommenen Daten und Statistiken dieser Einheit gehen dabei verloren und können nicht wiederhergestellt werden.'''
          '''\nWillst du diese Einheit wirklich löschen?''',
      onConfirm: onConfirm,
      successMessage: Constants.successDeleted,
      shouldNavigateHome: shouldNavigateHome,
    );
  }

  static Future<void> showDeleteInstance(
    BuildContext context, {
    required Future<void> Function() onConfirm,
  }) {
    return _show(
      context,
      title: 'Durchgeführte Sitzung löschen?',
      content: 'Alle aufgenommenen Daten dieser Einheit gehen dabei verloren.',
      onConfirm: onConfirm,
      successMessage: Constants.successDeleted,
      shouldNavigateHome: false,
    );
  }

  static Future<void> showArchive(
    BuildContext context, {
    required Future<void> Function() onConfirm,
  }) {
    return _show(
      context,
      title: 'Lerneinheit archivieren?',
      content:
          'Wenn du diese Einheit archivierst, wirst du sie nicht länger bearbeiten oder durchführen können.',
      onConfirm: onConfirm,
      successMessage: 'Erfolgreich archiviert',
      shouldNavigateHome: true,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String content,
    required String successMessage,
    required Future<void> Function() onConfirm,
    required bool shouldNavigateHome,
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
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              await onConfirm();

              if (context.mounted) {
                context.scaffoldMessenger.showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(successMessage),
                  ),
                );

                if (shouldNavigateHome) {
                  // Navigate back home in case of deletion!
                  await Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (Route<dynamic> route) => false,
                  );
                }
              }
            },
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );
  }
}
