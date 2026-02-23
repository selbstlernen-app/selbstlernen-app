import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/learning_strategy/learning_strategy_with_stats.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
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
  int? _isEditId;

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

  void _editStrategy(LearningStrategyWithStats strategy) {
    setState(() {
      _isEditId = strategy.strategyId;
      _strategyTitleController.text = strategy.title;
      _strategyExplanationController.text = strategy.explanation ?? '';
    });
  }

  Future<void> _addCustomStrategy() async {
    final state = ref.read(settingsViewModelProvider);
    final title = _strategyTitleController.text.trim();

    final isDuplicate = state.learningStrategies!.any(
      (strat) =>
          strat.title.toLowerCase() == title.toLowerCase() &&
          strat.strategyId != _isEditId,
    );
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diese Strategie existiert bereits.')),
      );
      return;
    }

    final notifier = ref.read(settingsViewModelProvider.notifier);

    if (_isEditId != null) {
      try {
        await notifier.updateStrategy(
          LearningStrategyModel(
            title: title,
            explanation: _strategyExplanationController.text.trim(),
          ),
          _isEditId!,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Strategie erfolgreich bearbeitet!')),
        );
      } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etwas ist schiefgelaufen: $e!')),
        );
      }
    } else {
      try {
        await notifier.addStrategy(
          title,
          _strategyExplanationController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Strategie erfolgreich hinzufgefügt!')),
        );
      } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etwas ist schiefgelaufen: $e!')),
        );
      }
    }

    _strategyTitleController.clear();
    _strategyExplanationController.clear();
    setState(() {
      _isEditId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final strategies = state.learningStrategies ?? [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Meine Strategien',
          style: context.textTheme.headlineLarge,
          textAlign: TextAlign.center,
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

                if (_isEditMode)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Füge eine Strategie hinzu',
                            style: context.textTheme.labelLarge,
                          ),
                          const VerticalSpace(size: SpaceSize.small),

                          CustomTextField(
                            hintText: 'Titel der Strategie',
                            controller: _strategyTitleController,
                          ),

                          const VerticalSpace(
                            size: SpaceSize.small,
                          ),

                          CustomTextField(
                            hintText: 'Optional: Erklärung der Strategie',
                            controller: _strategyExplanationController,
                            maxLength: 200,
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

                const VerticalSpace(),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.learningStrategies?.length ?? 0,
                  itemBuilder: (context, index) {
                    final strat = state.learningStrategies![index];

                    if (strat.strategyId == _isEditId) {
                      return const SizedBox.shrink();
                    }

                    return _StrategyTile(
                      strat: strat,
                      isEditMode: _isEditMode,
                      onDelete: () => ref
                          .read(settingsViewModelProvider.notifier)
                          .deleteStrategy(
                            strat.strategyId,
                          ),
                      onEdit: () => _editStrategy(strat),
                    );
                  },
                ),
              ],
            ),

            const VerticalSpace(),
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
    required this.onEdit,
  });

  final LearningStrategyWithStats strat;
  final bool isEditMode;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  State<_StrategyTile> createState() => _StrategyTileState();
}

class _StrategyTileState extends State<_StrategyTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasExplanation =
        widget.strat.explanation == null ||
        widget.strat.explanation!.isNotEmpty;

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
                // Show delete/edit button or expansion button depending on mode
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.isEditMode
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.mode_edit_outline_outlined,
                                color: AppPalette.blue,
                              ),
                              onPressed: widget.onEdit,
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppPalette.red,
                              ),
                              onPressed: widget.onDelete,
                            ),
                          ],
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
              curve: Curves.ease,
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
