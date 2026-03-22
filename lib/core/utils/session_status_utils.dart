import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class SessionStatusUtils {
  /// Method with which to get icons based on the session instance's status
  static IconData getIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.skipped:
        return Icons.skip_next;
      case SessionStatus.inProgress:
        return Icons.timelapse;
      case SessionStatus.scheduled:
        return Icons.circle_outlined;
      case SessionStatus.missed:
        return Icons.warning_amber_rounded;
    }
  }

  static Color getColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return AppPalette.emerald;
      case SessionStatus.skipped:
        return AppPalette.yellow;
      case SessionStatus.scheduled:
        return AppPalette.blue;
      case SessionStatus.inProgress:
        return AppPalette.blue;
      case SessionStatus.missed:
        return AppPalette.rose;
    }
  }

  static Widget getIconBox({required SessionStatus status, double? size}) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(status),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          getIcon(status),
          color: Colors.white,
          size: size ?? 20,
        ),
      ),
    );
  }

  static String getSubtitle(
    SessionStatus status,
  ) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'Anstehend';
      case SessionStatus.inProgress:
        return 'In Bearbeitung';
      case SessionStatus.skipped:
        return 'Übersprungen';
      case SessionStatus.completed:
        return 'Abgeschlossen';
      case SessionStatus.missed:
        return 'Verpasst';
    }
  }
}
