import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class PromptPage extends ConsumerStatefulWidget {
  const PromptPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _$PromptPageState();
}

class _$PromptPageState extends ConsumerState<PromptPage> {
  late TextEditingController _focusPromptController;

  @override
  void initState() {
    super.initState();
    _focusPromptController = TextEditingController();

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(addSessionViewModelProvider);
      _focusPromptController.text = state.focusPromptInterval.toString();
    });
  }

  @override
  void dispose() {
    _focusPromptController.dispose();
    super.dispose();
  }

  void _switchValues({
    bool? focus,
    int? focusPromptInterval,
    bool? showFocusPromptAlways,
  }) {
    ref
        .read(addSessionViewModelProvider.notifier)
        .setPrompts(
          focus: focus,
          focusPromptInterval: focusPromptInterval,
          showFocusPromptAlways: showFocusPromptAlways,
        );
  }

  Future<void> _handleSaveSession() async {
    try {
      final notifier = ref.read(addSessionViewModelProvider.notifier);
      final state = ref.read(addSessionViewModelProvider);

      await notifier.handleSaveSession();
      if (!mounted) return;

      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(Constants.successCreated),
        ),
      );

      if (state.isEditMode) {
        Navigator.pop(context);
      } else {
        await Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (Route<dynamic> route) => false,
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Fehler: $e'),
        ),
      );
    }
  }

  Future<void> _startSession() async {
    try {
      final instance = await ref
          .read(addSessionViewModelProvider.notifier)
          .handleStartSession();

      if (!mounted) return;

      await Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.active,
        arguments: ActiveSessionArgs(
          instanceId: int.parse(instance.id!),
          sessionId: int.parse(instance.sessionId),
        ),
        (Route<dynamic> route) => false,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Fehler: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Text(
              'Abfragen während der Lerneinheit',
              style: context.textTheme.headlineMedium,
            ),

            const VerticalSpace(),

            Text('Fokusabfrage', style: context.textTheme.headlineSmall),
            const VerticalSpace(size: SpaceSize.xsmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '''Konfiguriere eine Abfrage, die während der Lerneinheit deine Aufmerksamkeit testet.''',
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: state.hasFocusPrompt
                          ? context.colorScheme.onSurface
                          : context.colorScheme.onTertiary,
                    ),
                  ),
                ),
                Theme(
                  data: ThemeData(useMaterial3: true).copyWith(
                    colorScheme: context.colorScheme.copyWith(
                      outline: context.colorScheme.onTertiary,
                    ),
                  ),
                  child: Switch(
                    value: state.hasFocusPrompt,
                    inactiveThumbColor: context.colorScheme.onTertiary,
                    onChanged: (bool value) {
                      _switchValues(focus: value);
                    },
                  ),
                ),
              ],
            ),

            if (state.hasFocusPrompt) ...<Widget>[
              const VerticalSpace(),
              TimeInputField(
                minValue: 10,
                maxValue: 120,
                controller: _focusPromptController,
                label: 'Abfrage alle (min)',
                onChanged: (int value) {
                  _switchValues(focusPromptInterval: value);
                },
              ),

              const VerticalSpace(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      onPressed: () =>
                          _switchValues(showFocusPromptAlways: false),
                      label: 'Nach Inaktvität',
                      isActive: !state.showFocusPromptAlways,
                      borderLeft: true,
                      verticalPadding: 8,
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      onPressed: () =>
                          _switchValues(showFocusPromptAlways: true),
                      label: 'Immer',
                      isActive: state.showFocusPromptAlways,
                      borderRight: true,
                      verticalPadding: 8,
                    ),
                  ),
                ],
              ),
              const VerticalSpace(),
              Text(
                !state.showFocusPromptAlways
                    ? '''Bekomme die Abfrage nach ${state.focusPromptInterval} min Inaktvität (d.h. du hast für diese Zeit den Bildschirm nicht berührt).'''
                    : '''Bekomme die Abfrage immer, unabhängig von Bildschirm-Aktivität.''',
                style: context.textTheme.bodyMedium,
              ),
              const VerticalSpace(size: SpaceSize.small),
            ],
          ]),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: CustomButton(
                      verticalPadding: 8,
                      label: state.isEditMode
                          ? 'Mit Änderungen starten'
                          : 'Sofort starten',
                      onPressed: _startSession,
                    ),
                  ),

                  const HorizontalSpace(size: SpaceSize.small),
                  Expanded(
                    child: CustomButton(
                      verticalPadding: 8,
                      label: state.isEditMode
                          ? 'Änderungen speichern'
                          : 'Einheit erstellen',
                      onPressed: _handleSaveSession,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
