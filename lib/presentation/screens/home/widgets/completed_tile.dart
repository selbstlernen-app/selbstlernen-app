import 'package:flutter/material.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/home/utils/tile_helper.dart';

class CompletedSessionTile extends StatelessWidget {
  const CompletedSessionTile({required this.sessionWithInstance, super.key});

  final SessionWithInstanceModel sessionWithInstance;

  Widget _getIconBox(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(sessionWithInstance.instance!.status),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          getIcon(sessionWithInstance.instance!.status),
          color: context.colorScheme.onPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = sessionWithInstance.session;
    final instance = sessionWithInstance.instance!;

    return Card(
      elevation: 0.5,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.detail,
          arguments: DetailSessionArgs(
            sessionId: int.parse(session.id!),
            instanceId: int.parse(instance.id!),
          ),
        ),
        child: ListTile(
          title: Text(session.title, style: context.textTheme.headlineSmall),
          subtitle: Text(
            instance.status == SessionStatus.skipped
                ? 'Übersprungen'
                : 'Erledigt',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: _getIconBox(context),
          trailing: IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.detail,
              arguments: DetailSessionArgs(
                sessionId: int.parse(session.id!),
                instanceId: int.parse(instance.id!),
              ),
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            color: context.colorScheme.onTertiary,
          ),
        ),
      ),
    );
  }
}
