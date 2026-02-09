import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:srl_app/common_widgets/session_dialogs.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/session_status_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class PendingSessionTile extends ConsumerWidget {
  const PendingSessionTile({
    required this.session,
    required this.hasInstance,
    super.key,
  });

  final SessionModel session;
  final bool hasInstance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);

    return Stack(
      clipBehavior: Clip.antiAlias,
      children: <Widget>[
        const Positioned.fill(
          child: Card(
            color: AppPalette.amber,
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
                  icon: Icons.skip_next,
                  label: 'Überspringen',
                  onPressed: (BuildContext slidableContext) async {
                    await SessionDialogs.showSkipSession(
                      slidableContext,
                      onConfirm: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .skipSession(sessionId: session.id!);

                        if (slidableContext.mounted) {
                          ScaffoldMessenger.of(slidableContext).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('Lerneinheit übersprungen!'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: ListTile(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: DetailSessionArgs(
                      sessionId: int.parse(session.id!),
                      targetDate: homeState.dateToFilterFor,
                    ),
                  );
                },
                title: Text(
                  session.title,
                  style: context.textTheme.headlineSmall,
                ),
                subtitle: Text(
                  getSubtitle(
                    hasInstance
                        ? SessionStatus.inProgress
                        : SessionStatus.scheduled,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: getIconBox(
                  status: hasInstance
                      ? SessionStatus.inProgress
                      : SessionStatus.scheduled,
                ),
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
  }
}
