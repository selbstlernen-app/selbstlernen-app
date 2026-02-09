import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:srl_app/common_widgets/session_dialogs.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';

class ArchivedSessionTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        const Positioned.fill(
          child: Card(
            color: AppPalette.rose,
          ),
        ),
        ClipRRect(
          child: Slidable(
            key: ValueKey<int>(int.parse(session.id!)),
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              children: <Widget>[
                SlidableAction(
                  backgroundColor: Colors.transparent,
                  icon: Icons.delete_sweep_rounded,
                  label: 'Löschen',
                  onPressed: (BuildContext slidableContext) async {
                    await SessionDialogs.showDeleteSession(
                      slidableContext,
                      shouldNavigateHome: false,
                      isRepeating: session.isRepeating,
                      onConfirm: () async {
                        final useCase = ref.read(fullSessionUseCaseProvider);
                        await useCase.deleteFullModel(int.parse(session.id!));
                      },
                    );
                  },
                ),
              ],
            ),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: ListTile(
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
                title: Text(
                  session.title,
                  style: context.textTheme.headlineSmall,
                ),
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
              ),
            ),
          ),
        ),
      ],
    );
    // return Card(
    //   child: ListTile(
    //     onTap: () =>
    //         Navigator.of(
    //           context,
    //         ).pushNamed(
    //           AppRoutes.stats,
    //           arguments: SessionStatisticsArgs(
    //             sessionId: int.parse(session.id!),
    //             showGeneralStatsOnly: true,
    //           ),
    //         ),
    //     title: Text(session.title, style: context.textTheme.headlineSmall),
    //     subtitle: Text(
    //       session.isArchived ? 'Archiviert' : 'Aktuell laufend',
    //     ),
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     leading: _getIconBox(context),

    //     trailing: Icon(
    //       Icons.chevron_right,
    //       color: context.colorScheme.onSurfaceVariant,
    //     ),
    //   ),
    // );
  }
}
