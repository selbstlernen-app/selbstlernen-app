import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/home/utils/tile_helper.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          const Positioned.fill(
            child: Card(
              elevation: 0.5,
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
                    onPressed: (BuildContext slidableContext) async {
                      await _showSkipDialog(context, ref);
                    },
                    backgroundColor: Colors.transparent,
                    icon: Icons.skip_next,
                    label: 'Überspringen',
                  ),
                ],
              ),
              child: Card(
                elevation: 0.5,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.detail,
                    arguments: DetailSessionArgs(
                      sessionId: int.parse(session.id!),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      session.title,
                      style: context.textTheme.headlineSmall,
                    ),
                    subtitle: Text(
                      getSubtitle(
                        hasInstance
                            ? SessionStatus.inProgress
                            : SessionStatus.scheduled,
                        session.isRepeating ? session.startDate : null,
                        isRepeating: session.isRepeating,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: getIconBox(
                      hasInstance
                          ? SessionStatus.inProgress
                          : SessionStatus.scheduled,
                    ),
                    trailing: IconButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.detail,
                        arguments: DetailSessionArgs(
                          sessionId: int.parse(session.id!),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      color: context.colorScheme.onTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSkipDialog(BuildContext context, WidgetRef ref) {
    Future<void> skipSession() async {
      await ref
          .read(homeViewModelProvider.notifier)
          .skipSession(sessionId: session.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Lerneinheit übersprungen!'),
          ),
        );

        Navigator.of(context).pop();
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Lerneinheit überspringen',
            style: context.textTheme.headlineMedium,
          ),
          content: Text(
            'Willst du diese Einheit wirklich überspringen?',
            style: context.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                overlayColor: context.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Abbrechen',
                style: context.textTheme.labelLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
            TextButton(onPressed: skipSession, child: const Text('Bestätigen')),
          ],
        );
      },
    );
  }
}
