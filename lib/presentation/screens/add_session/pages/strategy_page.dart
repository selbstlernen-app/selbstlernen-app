import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/presentation/screens/settings/pages/learning_strategy_settings_screen.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class StrategyPage extends ConsumerStatefulWidget {
  const StrategyPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends ConsumerState<StrategyPage> {
  late TextEditingController _strategyController;

  @override
  void initState() {
    super.initState();
    _strategyController = TextEditingController();
  }

  @override
  void dispose() {
    _strategyController.dispose();
    super.dispose();
  }

  Future<void> _navigateToLearningStrategiesSettings(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => const LearningStrategySettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Lernstrategien', style: context.textTheme.headlineMedium),
                const VerticalSpace(size: SpaceSize.xsmall),
                Text(
                  '''Strategien, die du anwenden willst,'''
                  ''' um deine Ziele oder Aufgaben zu erreichen.''',
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(),

                // Grid of learning strategies
                Wrap(
                  runSpacing: 8,
                  children: <Widget>[
                    ...state.availableStrategies!.map(
                      (LearningStrategyModel strategy) => SizedBox(
                        // Padding * 2 = 48
                        width: (context.mediaQuery.size.width - 48) / 2,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(addSessionViewModelProvider.notifier)
                              .toggleStrategy(strategy.title),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                value: state.learningStrategies.contains(
                                  strategy.title,
                                ),
                                onChanged: (_) => ref
                                    .read(addSessionViewModelProvider.notifier)
                                    .toggleStrategy(strategy.title),
                              ),
                              Flexible(
                                child: Text(
                                  strategy.title,
                                  style: context.textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                TextButton(
                  onPressed: () =>
                      _navigateToLearningStrategiesSettings(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Andere Strategien?'),
                ),
              ],
            ),
          ),
        ),
        // Navigation button
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: state.learningStrategies.isNotEmpty
                ? 'Weiter'
                : 'Wähle mind. 1 Strategien aus',
            onPressed: () => state.learningStrategies.isNotEmpty
                ? widget.navigateForward()
                : null,
            isActive: state.learningStrategies.isNotEmpty,
          ),
        ),
      ],
    );
  }
}
