import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class StrategyPage extends ConsumerStatefulWidget {
  const StrategyPage({super.key, required this.navigateForward});
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
    final String newStrategy = _strategyController.text.trim();
    if (newStrategy.isEmpty) return;

    ref.read(addSessionViewModelProvider.notifier).addStrategy(newStrategy);

    _strategyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Lernstrategien", style: context.textTheme.headlineMedium),
                const VerticalSpace(size: SpaceSize.small),
                Text(
                  "Strategien, die du anwenden willst, um deine Ziele oder Aufgaben zu erreichen.",
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(size: SpaceSize.large),

                // Grid of learning strategies
                Wrap(
                  children: <Widget>[
                    ...state.availableStrategies.map(
                      (String strategy) => SizedBox(
                        width: (MediaQuery.sizeOf(context).width - 56) / 2,
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
                              Flexible(child: Text(strategy)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const VerticalSpace(size: SpaceSize.medium),

                TextButton(
                  onPressed: () => setState(() {
                    _showInput = !_showInput;
                  }),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(8.0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_showInput ? "Abbrechen" : "Andere Strategien?"),
                ),

                if (_showInput) const VerticalSpace(size: SpaceSize.small),

                if (_showInput)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CustomTextField(
                          onSubmitted: (_) => _addCustomStrategy(),
                          controller: _strategyController,
                          hintText: "z.B. Notizen auf Papier machen",
                        ),
                      ),
                      const HorizontalSpace(size: SpaceSize.small),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addCustomStrategy,
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                          foregroundColor: context.colorScheme.onPrimary,
                          backgroundColor: context.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        // Navigation button
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: state.learningStrategies.length > 1
                ? "Weiter"
                : "Wähle mind. 2 Strategien aus",
            onPressed: () => state.learningStrategies.length > 1
                ? widget.navigateForward()
                : null,
            isActive: state.learningStrategies.length > 1,
          ),
        ),
      ],
    );
  }
}
