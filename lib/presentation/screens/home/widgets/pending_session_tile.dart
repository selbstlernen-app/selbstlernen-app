import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/presentation/screens/detail_session/session_detail_screen.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class PendingSessionTile extends ConsumerWidget {
  const PendingSessionTile({super.key, required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          ClipRRect(
            child: Slidable(
              key: ValueKey<int>(int.parse(session.id!)),
              direction: Axis.horizontal,
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: <Widget>[
                  SlidableAction(
                    autoClose: true,
                    onPressed: (BuildContext slidableContext) async {
                      await _showSkipDialog(context, ref);
                    },
                    backgroundColor: Colors.transparent,
                    icon: Icons.skip_next,
                    label: 'Überspringen',
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) =>
                        SessionDetailScreen(sessionId: int.parse(session.id!)),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppPalette.zinc,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      session.title,
                      style: context.textTheme.headlineSmall!.copyWith(
                        color: context.colorScheme.onSecondary,
                      ),
                    ),
                    subtitle: Text(_getDisplayDate()),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    leading: const Icon(Icons.circle_outlined),
                    trailing: IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              SessionDetailScreen(
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
          ),
        ],
      ),
    );
  }

  String _getDisplayDate() {
    if (!session.isRepeating) {
      return "Einmalig";
    } else {
      final DateTime? date = session.startDate;
      return "${date?.day}.${date?.month}.${date?.year}";
    }
  }

  Future<void> _showSkipDialog(BuildContext context, WidgetRef ref) {
    void skipSession() {
      ref
          .read(homeViewModelProvider.notifier)
          .skipSession(sessionId: session.id!);

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
