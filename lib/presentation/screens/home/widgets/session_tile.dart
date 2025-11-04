import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/presentation/screens/detail_session/session_detail_screen.dart';

class SessionTile extends ConsumerWidget {
  const SessionTile({super.key, required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          "${session.completedInstances} / ${session.totalInstances}",
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        leading: const Icon(Icons.school_rounded),
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
