import 'package:flutter/material.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  required Future<void> Function() onConfirm,
  required Future<void> Function() onCancel,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: subtitle != null
            ? Text(subtitle, style: Theme.of(context).textTheme.bodyMedium)
            : null,
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await onCancel();
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
