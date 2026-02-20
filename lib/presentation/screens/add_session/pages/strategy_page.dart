import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/info_dialogs.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/settings/pages/learning_strategy_settings_screen.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class StrategyPage extends ConsumerStatefulWidget {
  const StrategyPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends ConsumerState<StrategyPage> {
  late TextEditingController _focusController;
  late TextEditingController _strategyController;

  @override
  void initState() {
    super.initState();
    _strategyController = TextEditingController();
    _focusController = TextEditingController();

    _focusController.text = ref
        .read(addSessionViewModelProvider)
        .focusTimeMin
        .toString();
  }

  @override
  void dispose() {
    _strategyController.dispose();
    _focusController.dispose();
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
    final available = ref.watch(
      addSessionViewModelProvider.select((s) => s.availableStrategies),
    );
    final selectedIds = ref.watch(
      addSessionViewModelProvider.select((s) => s.learningStrategyIds),
    );

    final canNavigate = selectedIds.isNotEmpty;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.psychology_rounded,
                      ),
                      const HorizontalSpace(size: SpaceSize.small),
                      Text(
                        'Lernstrategien',
                        style: context.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      InfoDialogs.showLearningStrategyInfo(context),
                  icon: const Icon(Icons.info_outline),
                  color: context.colorScheme.primary,
                ),
              ],
            ),

            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              '''Strategien, die du in deiner Lerneinheit anwenden willst,''',
              style: context.textTheme.bodyMedium,
            ),
            const VerticalSpace(
              size: SpaceSize.small,
            ),

            // Grid of learning strategies
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
              ),
              itemCount: available?.length ?? 0,
              itemBuilder: (context, index) {
                final strategy = available![index];
                final strategyId = strategy.strategyId;

                return _StrategyItem(
                  strategyId: strategyId,
                  title: strategy.title,
                  isSelected: selectedIds.contains(strategyId),
                );
              },
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            TextButton(
              onPressed: () => _navigateToLearningStrategiesSettings(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Andere Strategien?'),
            ),

            const VerticalSpace(),
          ]),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: canNavigate
                        ? 'Weiter'
                        : 'Wähle mind. 1 Strategien aus',
                    onPressed: () =>
                        canNavigate ? widget.navigateForward() : null,
                    isActive: canNavigate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StrategyItem extends ConsumerWidget {
  const _StrategyItem({
    required this.title,
    required this.strategyId,
    required this.isSelected,
  });
  final String title;
  final int strategyId;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      title: Text(title, style: context.textTheme.bodyMedium),
      value: isSelected,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      onChanged: (_) => ref
          .read(addSessionViewModelProvider.notifier)
          .toggleStrategy(strategyId),
    );
  }
}
