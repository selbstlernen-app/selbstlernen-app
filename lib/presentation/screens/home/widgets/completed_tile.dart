import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/detail_session/session_detail_screen.dart';

class CompletedSessionTile extends StatelessWidget {
  const CompletedSessionTile({super.key, required this.sessionWithInstance});

  final SessionWithInstanceModel sessionWithInstance;

  Icon _getIcon() {
    final SessionStatus status = sessionWithInstance.instance!.status;
    switch (status) {
      case SessionStatus.completed:
        return const Icon(Icons.check_circle);
      case SessionStatus.skipped:
        return const Icon(Icons.skip_next);
      default:
        return const Icon(Icons.circle_outlined);
    }
  }

  Color _getColor() {
    final SessionStatus status = sessionWithInstance.instance!.status;
    switch (status) {
      case SessionStatus.completed:
        return AppPalette.pastelEmerald;
      case SessionStatus.skipped:
        return AppPalette.pastelViolet;
      default:
        return AppPalette.zinc;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SessionModel session = sessionWithInstance.session;
    final SessionInstanceModel instance = sessionWithInstance.instance!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: _getColor(),
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
        leading: _getIcon(),
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
        textColor: context.colorScheme.onSecondary,
        iconColor: context.colorScheme.onSecondary,
      ),
    );
  }
}
