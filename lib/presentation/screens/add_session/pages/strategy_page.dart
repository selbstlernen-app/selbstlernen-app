import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class StrategyPage extends ConsumerStatefulWidget {
  const StrategyPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends ConsumerState<StrategyPage> {
  bool _showInput = false;
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

  void _addCustomStrategy() {
    final newStrategy = _strategyController.text.trim();
    if (newStrategy.isEmpty) return;

    ref.read(addSessionViewModelProvider.notifier).addStrategy(newStrategy);

    _strategyController.clear();
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
                const VerticalSpace(size: SpaceSize.small),
                Text(
                  'Strategien, die du anwenden willst, um deine Ziele oder Aufgaben zu erreichen.',
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(),

                // Grid of learning strategies
                Wrap(
                  runSpacing: 8,
                  children: <Widget>[
                    ...state.availableStrategies.map(
                      (String strategy) => SizedBox(
                        // Padding * 2 = 48
                        width: (context.mediaQuery.size.width - 48) / 2,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(addSessionViewModelProvider.notifier)
                              .toggleStrategy(strategy),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                value: state.learningStrategies.contains(
                                  strategy,
                                ),
                                onChanged: (_) => ref
                                    .read(addSessionViewModelProvider.notifier)
                                    .toggleStrategy(strategy),
                              ),
                              Flexible(
                                child: Text(
                                  strategy,
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
                  onPressed: () => setState(() {
                    _showInput = !_showInput;
                  }),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_showInput ? 'Abbrechen' : 'Andere Strategien?'),
                ),

                if (_showInput) ...<Widget>[
                  const VerticalSpace(size: SpaceSize.small),
                  CustomAddItemField(
                    onSubmitted: _addCustomStrategy,
                    onPressed: _addCustomStrategy,
                    controller: _strategyController,
                    hintText: 'z.B. Notizen auf Papier machen',
                  ),
                ],
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
