import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/detail_session/session_detail_screen.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class SessionTile extends ConsumerWidget {
  const SessionTile({super.key, required this.sessionWithInstanceModel});

  final SessionWithInstanceModel sessionWithInstanceModel;

  // Get icon based on session status
  Icon _switchIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed || SessionStatus.skipped:
        return const Icon(Icons.check);
      default:
        return const Icon(Icons.circle_outlined);
    }
  }

  // Get color based on session status
  Color _switchColor(SessionStatus status, BuildContext context) {
    switch (status) {
      case SessionStatus.scheduled:
        return context.colorScheme.onTertiary;
      case SessionStatus.completed:
        return context.colorScheme.primary;
      case SessionStatus.skipped:
        return context.colorScheme.secondary;
      default:
        return context.colorScheme.onTertiary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionInstanceModel instance = sessionWithInstanceModel.instance!;
    final SessionModel session = sessionWithInstanceModel.session;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          Positioned.fill(
            child: Builder(
              builder: (BuildContext context) => Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          ClipRRect(
            child: Slidable(
              key: UniqueKey(),
              direction: Axis.horizontal,
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: <Widget>[
                  SlidableAction(
                    autoClose: false,
                    onPressed: (BuildContext slidableContext) async {
                      if (!sessionWithInstanceModel.isCompleted &&
                          !sessionWithInstanceModel.isSkipped) {
                        await skipInstanceDialog(context, ref, instance);
                      }
                    },
                    backgroundColor: Colors.transparent,
                    icon: Icons.skip_next,
                    label: 'Überspringen',
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _switchColor(instance.status, context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    session.title,
                    style: context.textTheme.headlineSmall!.copyWith(
                      color: context.colorScheme.onSecondary,
                    ),
                  ),
                  subtitle: Text(
                    "${instance.scheduledAt.day}.${instance.scheduledAt.month}.${instance.scheduledAt.year}",
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  leading: _switchIcon(instance.status),
                  trailing: IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => SessionDetailScreen(
                          sessionId: int.parse(session.id!),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),

                  textColor: context.colorScheme.onSecondary,
                  iconColor: context.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> skipInstanceDialog(
    BuildContext context,
    WidgetRef ref,
    SessionInstanceModel instance,
  ) {
    void skipSession() {
      ref.read(homeViewModelProvider.notifier).skipSession(instance);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Lerneinheit übersprungen!"),
        ),
      );

      Navigator.of(context).pop();
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
            "Willst du diese Einheit wirklich überspringen?",
            style: context.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                overlayColor: context.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Abbrechen",
                style: context.textTheme.labelLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
            TextButton(onPressed: skipSession, child: const Text("Bestätigen")),
          ],
        );
      },
    );
  }
}
