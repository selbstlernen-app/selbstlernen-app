import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/presentation/screens/settings/widgets/build_section.dart';
import 'package:srl_app/presentation/screens/settings/widgets/settings_tile.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late final _customMessageController = TextEditingController();
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();

    _lifecycleListener = AppLifecycleListener(
      onResume: () =>
          ref.read(settingsViewModelProvider.notifier).checkPermission(),
    );

    // Initialize custom motivational reminder if given
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(settingsViewModelProvider);
      final motivationNotification = state.notificationSettings!
          .where(
            (n) => n.type == NotificationType.motivationalReminder,
          )
          .first;

      final newText = motivationNotification.customMessage ?? '';
      _customMessageController.text = newText;
    });

    _customMessageController.addListener(() {
      // This ensures the 'Save' button appears/disappears as you type
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _addCustomMessage(NotificationTypeSetting setting) async {
    if (_customMessageController.text.trim().isEmpty) return;

    final notifier = ref.read(settingsViewModelProvider.notifier);

    await notifier.updateNotification(
      setting.type,
      setting.copyWith(customMessage: _customMessageController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Benachrichtigungen',
          style: context.textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            buildSection(
              context: context,
              title: 'Benachrichtigungen',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsTile(
                    title: 'Benachrichtigungen erlauben',
                    subtitle: state.hasNotificationPermission!
                        ? 'Benachrichtigungen sind aktiviert'
                        : '''Benachrichtigungen sind deaktiviert. Aktiviere sie und passe sie an deinen Bedarf an''',
                    isEnabled: state.hasNotificationPermission!,
                    onToggle: () async {
                      if (state.hasNotificationPermission ?? false) {
                        // If user has permissions on and want to toggle
                        // turn them off in settings of device:
                        await NotificationService().openNotificationSettings();
                        await NotificationService().cancelAllNotifications();
                        final activeSessions = ref.watch(
                          settingsViewModelProvider.select(
                            (s) => s.activeSessions,
                          ),
                        );
                        if (activeSessions!.isNotEmpty) {
                          for (final session in activeSessions) {
                            await notifier.updateSessionSettings(
                              session.copyWith(
                                hasNotification: !session.hasNotification,
                              ),
                              int.parse(session.id!),
                            );
                          }
                        }
                      } else {
                        // If they are off enable request
                        final granted = await NotificationService()
                            .requestPermission();
                        if (!granted) {
                          // If not granted (user clicked deny)
                          // open settings on device
                          await NotificationService()
                              .openNotificationSettings();
                        }
                      }
                    },
                  ),

                  ...state.notificationSettings!
                      .where(
                        (setting) =>
                            setting.type != NotificationType.sessionReminder,
                      )
                      .map(
                        (setting) => SettingsTile(
                          title: setting.type.displayName,
                          subtitle: setting.type.description,
                          isEnabled: setting.enabled,
                          onToggle: () async {
                            await notifier.toggleNotificationSetting(
                              setting: setting,
                              type: setting.type,
                              isEnabled: !setting.enabled,
                            );
                          },
                          // Expansion to set frequency and preferred time
                          // of notification
                          expandedChild: Column(
                            children: [
                              // Dropdown
                              DropdownButtonFormField<NotificationFrequency>(
                                initialValue: setting.frequency,
                                decoration: const InputDecoration(
                                  labelText: 'Häufigkeit',
                                  border: OutlineInputBorder(),
                                ),
                                items: NotificationFrequency.values
                                    .map(
                                      (f) => DropdownMenuItem(
                                        value: f,
                                        child: Text(f.displayName),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) async {
                                  if (value == null) return;
                                  await notifier.updateNotification(
                                    setting.type,
                                    setting.copyWith(
                                      frequency: value,
                                    ),
                                  );
                                },
                              ),
                              const VerticalSpace(
                                size: SpaceSize.small,
                              ),
                              // Time Setting
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: Text(
                                  'Bevorzugte Uhrzeit',
                                  style: context.textTheme.headlineSmall,
                                ),
                                subtitle: Text(
                                  setting.preferredTime?.format(context) ??
                                      'Keine Uhrzeit gewählt',
                                ),
                                trailing: const Icon(Icons.access_time),
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        setting.preferredTime ??
                                        TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    await notifier.updateNotification(
                                      setting.type,
                                      setting.copyWith(preferredTime: time),
                                    );
                                  }
                                },
                              ),

                              // Custom message setter
                              if (setting.type ==
                                  NotificationType.motivationalReminder) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const VerticalSpace(
                                      size: SpaceSize.small,
                                    ),
                                    CustomTextField(
                                      onSubmitted: (_) async {
                                        await _addCustomMessage(setting);
                                      },
                                      hintText:
                                          '''Eigene Erinnerung, z.B. "Dranbleiben! 🧠"''',
                                      controller: _customMessageController,
                                      maxLength: 70,
                                    ),

                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      opacity:
                                          _customMessageController.text
                                                  .trim() !=
                                              (setting.customMessage ?? '')
                                          ? 1.0
                                          : 0.0,
                                      child: IconButton(
                                        color: context.colorScheme.primary,
                                        onPressed:
                                            _customMessageController.text
                                                    .trim() !=
                                                (setting.customMessage ?? '')
                                            ? () async {
                                                await _addCustomMessage(
                                                  setting,
                                                );

                                                if (!context.mounted) return;
                                                FocusScope.of(
                                                  context,
                                                ).unfocus();
                                                context.scaffoldMessenger
                                                    .showSnackBar(
                                                      const SnackBar(
                                                        duration: Duration(
                                                          seconds: 1,
                                                        ),
                                                        content: Text(
                                                          'Nachricht gespeichert',
                                                        ),
                                                      ),
                                                    );
                                              }
                                            : null,
                                        icon: const Icon(
                                          Icons.save_as_outlined,
                                        ),
                                        tooltip: 'Speichern',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  const VerticalSpace(size: SpaceSize.small),
                  const _SettingNotificationList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingNotificationList extends ConsumerWidget {
  const _SettingNotificationList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessions = ref.watch(
      settingsViewModelProvider.select((s) => s.activeSessions),
    );

    final notifier = ref.watch(settingsViewModelProvider.notifier);

    return buildSection(
      context: context,
      title: 'Lerneinheit Erinnerungen',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          if (activeSessions != null && activeSessions.isEmpty)
            const Text('Keine offene Lerneinheit')
          else
            ...activeSessions!.map(
              (session) => SettingsTile(
                title: session.title,
                subtitle: session.isRepeating ? 'Wiederholend' : 'Einmalig',
                isEnabled: session.hasNotification,
                onToggle: () async {
                  await notifier.updateSessionSettings(
                    session.copyWith(hasNotification: !session.hasNotification),
                    int.parse(session.id!),
                  );
                },
                // Expansion to set frequency and preferred time
                // of notification
                expandedChild:
                    // Time Setting
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      title: Text(
                        'Bevorzugte Durchführzeit',
                        style: context.textTheme.headlineSmall,
                      ),
                      subtitle: Text(session.plannedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: session.plannedTime,
                        );
                        if (time != null) {
                          await notifier.updateSessionSettings(
                            session.copyWith(plannedTime: time),
                            int.parse(session.id!),
                          );
                        }
                      },
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
