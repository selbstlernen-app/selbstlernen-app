import 'package:flutter/material.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';

class ArchivedSessionTile extends StatelessWidget {
  const ArchivedSessionTile({required this.session, super.key});

  final SessionModel session;

  Widget _getIconBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: session.isArchived ? AppPalette.orange : AppPalette.fuchsiaLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          session.isArchived
              ? Icons.archive_rounded
              : Icons.access_time_filled_rounded,
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: context.colorScheme.surface,
      onTap: () =>
          Navigator.of(
            context,
          ).pushNamed(
            AppRoutes.stats,
            arguments: SessionStatisticsArgs(
              sessionId: int.parse(session.id!),
              showGeneralStatsOnly: true,
            ),
          ),
      title: Text(session.title, style: context.textTheme.headlineSmall),
      subtitle: Text(
        session.isArchived ? 'Archiviert' : 'Aktuell laufend',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: _getIconBox(context),

      trailing: Icon(
        Icons.chevron_right,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
