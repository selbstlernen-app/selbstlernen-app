import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/presentation/screens/settings/widgets/build_section.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class LearningStrategySettingsScreen extends ConsumerStatefulWidget {
  const LearningStrategySettingsScreen({super.key});

  @override
  ConsumerState<LearningStrategySettingsScreen> createState() =>
      _LearningStrategySettingsScreenState();
}

class _LearningStrategySettingsScreenState
    extends ConsumerState<LearningStrategySettingsScreen> {
  late final _customStrategyController = TextEditingController();

  @override
  void dispose() {
    _customStrategyController.dispose();
    super.dispose();
  }

  Future<void> _addCustomMessage(NotificationTypeSetting setting) async {
    if (_customStrategyController.text.trim().isEmpty) return;

    final notifier = ref.read(settingsViewModelProvider.notifier);

    // await notifier.updateNotification(
    //   setting.type,
    //   setting.copyWith(customMessage: _customStrategyController.text.trim()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lernstrategien',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            buildSection(
              context: context,
              title: 'Lernstrategien',
              child: Column(
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    children: state.learningStrategies!.map((strat) {
                      return GestureDetector(
                        // onTap: () => notifier.setPrimaryColor(color),
                        child: Column(
                          children: [
                            Text(strat.title),
                            Text(strat.explanation ?? ""),
                          ],
                        ),
                      );
                    }).toList(),
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
