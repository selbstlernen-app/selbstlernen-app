import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required Future<void> Function() onConfirm,
  required VoidCallback onCancel,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: content,
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              onCancel();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(
              cancelLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () async {
              await onConfirm();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}
