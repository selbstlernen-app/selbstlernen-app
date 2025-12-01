import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

/// Method with which to get icons based on the session instance's status
IconData getIcon(SessionStatus status) {
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

Color getColor(SessionStatus status) {
  switch (status) {
    case SessionStatus.completed:
      return AppPalette.emerald;
    case SessionStatus.skipped:
      return AppPalette.amber;
    case SessionStatus.scheduled:
      return AppPalette.teal;
    case SessionStatus.inProgress:
      return AppPalette.sky;
    case SessionStatus.missed:
      return AppPalette.indigo;
  }
}

Widget getIconBox(SessionStatus status) {
  return Container(
    decoration: BoxDecoration(
      color: getColor(status),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Icon(getIcon(status), color: Colors.white),
    ),
  );
}

String getSubtitle(
  SessionStatus status,
  DateTime? startDate, {
  required bool isRepeating,
}) {
  switch (status) {
    case SessionStatus.scheduled:
      if (startDate == null) {
        return isRepeating ? 'Geplant (Datum unbekannt)' : 'Einmalig geplant';
      }
      final dateStr = DateFormat('dd.MM.yyyy').format(startDate);
      return isRepeating ? 'Geplant am $dateStr' : 'Einmalig geplant';

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
