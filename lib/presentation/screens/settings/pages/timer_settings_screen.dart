import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/settings/widgets/build_section.dart';
import 'package:srl_app/presentation/screens/settings/widgets/settings_tile.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class TimerSettingsScreen extends ConsumerWidget {
  const TimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          textAlign: TextAlign.center,
          'Timer',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            buildSection(
              context: context,
              title: 'Timer',
              child: Column(
                children: [
                  SettingsTile(
                    title: 'Start Modus',
                    subtitle: state.timerStartsAutomatically
                        ? '''Der Timer soll automatisch beim Eintreten der Lerneinheit gestartet werden'''
                        : '''Der Timer muss bei jeder Lerneinheit manuell gestartet werden''',
                    isEnabled: state.timerStartsAutomatically,
                    onToggle: notifier.toggleTimerAutomaticallyStarted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
