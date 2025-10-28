import 'package:flutter/material.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_model.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({super.key, required this.session});

  final SessionModel session;

  @override
  Widget build(BuildContext context) {
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
          session.isRepeating ? session.startDate.toString() : "Einmalig",
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        leading: const Icon(Icons.leaderboard_outlined),
        trailing: IconButton(
          onPressed: () => print("lol"),
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
        tileColor: context.colorScheme.secondary,
        textColor: context.colorScheme.onSecondary,
        iconColor: context.colorScheme.onSecondary,
      ),
    );
  }
}
