import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/common_widgets/custom_filter_chip.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<SetupWizardPage> createState() => _$SetupWizardPageState();
}

class _$SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(addSessionViewModelProvider);
      _titleController.text = state.title;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editMode = ref.watch(
      addSessionViewModelProvider.select((s) => s.isEditMode),
    );
    final titleError = ref.watch(
      addSessionViewModelProvider.select((s) => s.titleError),
    );

    final canGoToSecondStep = ref.watch(
      addSessionViewModelProvider.select((s) => s.canGoToSecondStep),
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Titel der Lerneinheit',
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.small),
                CustomTextField(
                  readOnly: editMode,
                  onChanged: ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTitle,
                  controller: _titleController,
                  hintText: 'z.B. Info 1 - Vorlesung 3...',
                  maxLength: 35,
                  hasError: titleError != null,
                ),
                if (titleError != null) CustomErrorText(errorText: titleError),

                const VerticalSpace(
                  size: SpaceSize.large,
                ),

                // Frequency + Info Text
                const _FrequencySetting(),

                const VerticalSpace(
                  size: SpaceSize.xlarge,
                ),

                const _LearntimeSetting(),
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: 'Weiter',
            isActive: canGoToSecondStep,
            onPressed: () =>
                canGoToSecondStep ? widget.navigateForward() : null,
          ),
        ),
      ],
    );
  }
}

class _FrequencySetting extends ConsumerWidget {
  const _FrequencySetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editMode = ref.watch(
      addSessionViewModelProvider.select((s) => s.isEditMode),
    );
    final isRepeating = ref.watch(
      addSessionViewModelProvider.select((s) => s.isRepeating),
    );

    return Column(
      children: [
        Row(
          children: <Widget>[
            const Icon(
              Icons.event_repeat_rounded,
            ),
            const HorizontalSpace(size: SpaceSize.small),
            Text('Häufigkeit', style: context.textTheme.headlineSmall),
          ],
        ),

        const VerticalSpace(),
        Row(
          children: <Widget>[
            CustomFilterChip(
              label: 'Einmalig',
              isActive: !isRepeating,
              onPressed: () => editMode
                  ? null
                  : ref
                        .read(addSessionViewModelProvider.notifier)
                        .setIsRepeating(isRepeating: false),
            ),

            const HorizontalSpace(size: SpaceSize.small),

            CustomFilterChip(
              label: 'Wiederholend',
              isActive: isRepeating,
              onPressed: () => editMode
                  ? null
                  : ref
                        .read(addSessionViewModelProvider.notifier)
                        .setIsRepeating(isRepeating: true),
            ),
          ],
        ),
        const VerticalSpace(size: SpaceSize.small),
        AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
          child: isRepeating
              ? const Text(
                  key: ValueKey('habit_text'),
                  '''Etabliere feste Gewohnheiten. Plane deine Tage und schaffe eine Routine.''',
                )
              : const Text(
                  key: ValueKey('once_text'),
                  '''Einmalige Einheit ohne festen Zeitplan, geeignet für gezielte Aufgaben oder Projekte.''',
                ),
        ),
      ],
    );
  }
}

class _LearntimeSetting extends ConsumerWidget {
  const _LearntimeSetting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editMode = ref.watch(
      addSessionViewModelProvider.select((s) => s.isEditMode),
    );
    final sessionComplexity = ref.watch(
      addSessionViewModelProvider.select((s) => s.sessionComplexity),
    );

    return Column(
      children: [
        Row(
          children: <Widget>[
            const Icon(
              Icons.timer_outlined,
            ),
            const HorizontalSpace(size: SpaceSize.small),
            Text(
              'Lernzeit-Art auswählen',
              style: context.textTheme.headlineSmall,
            ),
          ],
        ),

        const VerticalSpace(),
        Row(
          children: <Widget>[
            CustomFilterChip(
              label: 'Reine Lernzeit',
              isActive: sessionComplexity == SessionComplexity.simple,
              onPressed: () => editMode
                  ? null
                  : ref
                        .read(addSessionViewModelProvider.notifier)
                        .setSessionComplexity(
                          complexity: SessionComplexity.simple,
                        ),
            ),

            const HorizontalSpace(size: SpaceSize.small),
            CustomFilterChip(
              label: 'Pomodoro Lernzeit',
              isActive: sessionComplexity == SessionComplexity.advanced,
              onPressed: () => editMode
                  ? null
                  : ref
                        .read(addSessionViewModelProvider.notifier)
                        .setSessionComplexity(
                          complexity: SessionComplexity.advanced,
                        ),
            ),
          ],
        ),
        const VerticalSpace(size: SpaceSize.small),
        AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
          child: sessionComplexity == SessionComplexity.simple
              ? const Text(
                  key: ValueKey('simple_mode'),
                  '''Ein klassischer Timer für ungestörtes Lernen. Ideal für tiefe Konzentration am Stück.''',
                )
              : const Text(
                  key: ValueKey('advanced_mode'),
                  '''Nutze die Pomodoro-Methode mit festen Fokus- und Pausenzeiten für maximale Produktivität.''',
                ),
        ),
      ],
    );
  }
}
