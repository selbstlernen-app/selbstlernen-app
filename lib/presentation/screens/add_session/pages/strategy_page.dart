import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
import 'package:srl_app/presentation/screens/settings/pages/learning_strategy_settings_screen.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
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
    final selected = ref.watch(
      addSessionViewModelProvider.select((s) => s.learningStrategies),
    );
    final canNavigate = selected.isNotEmpty;
    final isSimpleTimer = ref.watch(
      addSessionViewModelProvider.select(
        (s) => s.sessionComplexity == SessionComplexity.simple,
      ),
    );
    final focusTime = ref.watch(
      addSessionViewModelProvider.select((s) => s.focusTimeMin),
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: <Widget>[
                const Icon(
                  Icons.wb_incandescent_outlined,
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Text(
                  'Lernstrategien',
                  style: context.textTheme.headlineSmall,
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
                return _StrategyItem(
                  strategy: strategy,
                  isSelected: selected.contains(strategy.title),
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
            // Simple Timer (*IF chosen in wizard)
            if (isSimpleTimer) _buildSimpleTimeSettings(focusTime),
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

  Widget _buildSimpleTimeSettings(int focusTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            const Icon(
              Icons.timer_outlined,
            ),
            const HorizontalSpace(size: SpaceSize.small),
            Text(
              'Fokuszeit festlegen',
              style: context.textTheme.headlineSmall,
            ),
          ],
        ),
        const VerticalSpace(),

        TimeInputField(
          controller: _focusController,
          onChanged: (int value) {
            ref
                .read(addSessionViewModelProvider.notifier)
                .setTimerSettings(focusTime: value);
          },
        ),

        const VerticalSpace(size: SpaceSize.xsmall),

        Divider(
          color: context.colorScheme.tertiary,
          thickness: 4,
          radius: BorderRadius.circular(10),
        ),

        Text('Gesamtzeit: ${focusTime ~/ 60}h ${focusTime % 60} min'),

        const VerticalSpace(size: SpaceSize.small),
      ],
    );
  }
}

class _StrategyItem extends ConsumerWidget {
  const _StrategyItem({required this.strategy, required this.isSelected});
  final LearningStrategyModel strategy;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      title: Text(strategy.title, style: context.textTheme.bodyMedium),
      value: isSelected,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      onChanged: (_) => ref
          .read(addSessionViewModelProvider.notifier)
          .toggleStrategy(strategy.title),
    );
  }
}
