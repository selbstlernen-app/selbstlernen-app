import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/detail_session/session_detail_screen.dart';

class SessionTile extends ConsumerWidget {
  const SessionTile({super.key, required this.sessionWithInstanceModel});

  final SessionWithInstanceModel sessionWithInstanceModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionInstanceModel instance = sessionWithInstanceModel.instance!;
    final SessionModel session = sessionWithInstanceModel.session;
    print(sessionWithInstanceModel);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        leading: sessionWithInstanceModel.isCompleted
            ? const Icon(Icons.check_rounded)
            : const Icon(Icons.circle_outlined),
        trailing: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<dynamic>(
              builder: (BuildContext context) =>
                  SessionDetailScreen(sessionId: int.parse(session.id!)),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        tileColor: context.colorScheme.secondary,
        textColor: context.colorScheme.onSecondary,
        iconColor: context.colorScheme.onSecondary,
      ),
    );
  }
}
