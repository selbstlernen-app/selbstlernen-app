import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/notification_service.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Benachrichtigungen',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection(
              context: context,
              title: 'Benachrichtigungen',
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Benarichtigungen erlauben',
                          style: context.textTheme.headlineSmall,
                        ),
                      ),
                      subtitle: const Text(
                        'Deine Benachrichtigungen sind deaktiviert. Aktiviere sie und passe sie an deinen Bedarf an',
                      ),
                      trailing: Switch(
                        value: state.hasNotificationPermission!,
                        onChanged: (_) =>
                            NotificationService().openNotificationSettings,
                      ),
                      onTap: NotificationService().openNotificationSettings,
                    ),
                  ),

                  ...state.notificationSettings!.map((e) => Text(e.type.name)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineSmall),

        const VerticalSpace(),

        child,
      ],
    );
  }
}
