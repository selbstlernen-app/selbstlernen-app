import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
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
  late final _strategyTitleController = TextEditingController();
  late final _strategyExplanationController = TextEditingController();

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _strategyTitleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _strategyTitleController.dispose();
    _strategyExplanationController.dispose();
    super.dispose();
  }

  Future<void> _addCustomStrategy() async {
    final state = ref.read(settingsViewModelProvider);
    final title = _strategyTitleController.text.trim();

    if ((state.learningStrategies?.length ?? 0) >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximal 15 Strategien erlaubt.')),
      );
      return;
    }

    final isDuplicate = state.learningStrategies!.any(
      (strat) => strat.title.toLowerCase() == title.toLowerCase(),
    );
    if (isDuplicate) return;

    final notifier = ref.read(settingsViewModelProvider.notifier);
    await notifier.addStrategy(
      title,
      _strategyExplanationController.text.trim(),
    );

    _strategyTitleController.clear();
    _strategyExplanationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final strategies = state.learningStrategies ?? [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Meine Strategien (${strategies.length}/15)',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lernstrategien',
                      style: context.textTheme.headlineMedium,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: CustomIconButton(
                        radius: 40,
                        icon: Icon(
                          _isEditMode ? Icons.edit_off_outlined : Icons.edit,
                        ),
                        label: _isEditMode ? 'Fertig' : 'Bearbeiten',
                        isActive: true,
                        onPressed: () =>
                            setState(() => _isEditMode = !_isEditMode),
                      ),
                    ),
                  ],
                ),

                const VerticalSpace(),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.learningStrategies?.length ?? 0,
                  itemBuilder: (context, index) {
                    final strat = state.learningStrategies![index];
                    return _StrategyTile(
                      strat: strat,
                      isEditMode: _isEditMode,
                      onDelete: () => ref
                          .read(settingsViewModelProvider.notifier)
                          .deleteStrategy(
                            int.parse(
                              strat.id!,
                            ),
                          ),
                    );
                  },
                ),
              ],
            ),

            const VerticalSpace(),

            if (strategies.length < 15)
              buildSection(
                context: context,
                title: 'Strategie hinzufügen',
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomTextField(
                          hintText: 'Titel der Strategie',
                          controller: _strategyTitleController,
                        ),

                        const VerticalSpace(),
                        CustomTextField(
                          hintText: 'Optional: Erklärung der Strategie',
                          controller: _strategyExplanationController,
                          maxLength: 100,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity:
                                  _strategyTitleController.text.trim() != ''
                                  ? 1.0
                                  : 0.0,
                              child: IconButton(
                                color: context.colorScheme.primary,
                                onPressed:
                                    _strategyTitleController.text.trim() != ''
                                    ? () async {
                                        await _addCustomStrategy();
                                        if (!context.mounted) return;
                                        FocusScope.of(context).unfocus();
                                      }
                                    : null,
                                icon: const Icon(Icons.save_as_outlined),
                                tooltip: 'Speichern',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StrategyTile extends StatefulWidget {
  const _StrategyTile({
    required this.strat,
    required this.isEditMode,
    required this.onDelete,
  });

  final LearningStrategyModel strat;
  final bool isEditMode;
  final VoidCallback onDelete;

  @override
  State<_StrategyTile> createState() => _StrategyTileState();
}

class _StrategyTileState extends State<_StrategyTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasExplanation =
        widget.strat.explanation != '' || widget.strat.explanation == null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.strat.title,
                  style: context.textTheme.labelLarge,
                ),
                // Show delete button or expansion button depending on mode
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isEditMode
                      ? IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: widget.onDelete,
                        )
                      : (hasExplanation
                            ? IconButton(
                                icon: Icon(
                                  _isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () => setState(
                                  () => _isExpanded = !_isExpanded,
                                ),
                              )
                            : const SizedBox.shrink()),
                ),
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _isExpanded && hasExplanation && !widget.isEditMode
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.strat.explanation!,
                        style: context.textTheme.bodyMedium,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
