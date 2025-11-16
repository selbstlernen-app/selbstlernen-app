import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/active_session/active_session_screen.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/time_input_field.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class PromptPage extends ConsumerStatefulWidget {
  const PromptPage({super.key, required this.navigateForward});
  final VoidCallback navigateForward;

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
      final AddSessionState state = ref.read(addSessionViewModelProvider);
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
    bool? freetext,
  }) {
    ref
        .read(addSessionViewModelProvider.notifier)
        .setPrompts(
          focus: focus,
          focusPromptInterval: focusPromptInterval,
          showFocusPromptAlways: showFocusPromptAlways,
          freetext: freetext,
        );
  }

  Future<void> _saveSession() async {
    try {
      await ref.read(addSessionViewModelProvider.notifier).createSession();
      if (!mounted) return;

      context.scaffoldMessenger.showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Einheit erfolgreich gespeichert!"),
        ),
      );

      await Navigator.of(
        context,
      ).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
    } catch (e) {
      if (!mounted) return;
      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Fehler: $e'),
        ),
      );
    }
  }

  Future<void> _updateSession() async {
    try {
      await ref.read(addSessionViewModelProvider.notifier).updateSession();
      if (!mounted) return;
      context.scaffoldMessenger.showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Änderungen erfolgreich gespeichert!!"),
        ),
      );

      await Navigator.of(
        context,
      ).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
    } catch (e) {
      if (!mounted) return;
      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('Fehler: $e'),
        ),
      );
    }
  }

  Future<void> _startSession(bool isEditingMode) async {
    try {
      if (isEditingMode) {
        await ref.read(addSessionViewModelProvider.notifier).updateSession();
      } else {
        await ref.read(addSessionViewModelProvider.notifier).createSession();
      }

      SessionInstanceModel instance = await ref
          .read(addSessionViewModelProvider.notifier)
          .startSession(DateTime.now());

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => ActiveSessionScreen(
            instanceId: int.parse(instance.id!),
            sessionId: int.parse(instance.sessionId),
          ),
        ),
      );
    } catch (e) {
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
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Abfragen während einer Lerneinheit",
                  style: context.textTheme.headlineMedium,
                ),

                const VerticalSpace(size: SpaceSize.medium),

                Text("Fokusabfrage", style: context.textTheme.headlineSmall),
                const VerticalSpace(size: SpaceSize.small),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Konfiguriere eine Abfrage, die während einer Lerneinheit deine Aufmerksamkeit testet.",
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
                  const VerticalSpace(size: SpaceSize.medium),
                  TimeInputField(
                    minValue: 10,
                    maxValue: 120,
                    controller: _focusPromptController,
                    label: "Abfrage alle (min)",
                    onChanged: (int value) {
                      _switchValues(focusPromptInterval: value);
                    },
                  ),

                  const VerticalSpace(size: SpaceSize.medium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: CustomButton(
                          onPressed: () =>
                              _switchValues(showFocusPromptAlways: false),
                          label: "Nach Inaktvität",
                          isActive: !state.showFocusPromptAlways,
                          borderLeft: true,
                          verticalPadding: 8.0,
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          onPressed: () =>
                              _switchValues(showFocusPromptAlways: true),
                          label: "Immer",
                          isActive: state.showFocusPromptAlways,
                          borderRight: true,
                          verticalPadding: 8.0,
                        ),
                      ),
                    ],
                  ),
                  const VerticalSpace(size: SpaceSize.medium),
                  Text(
                    !state.showFocusPromptAlways
                        ? "Bekomme die Abfrage nach ${state.focusPromptInterval} min Inaktvität (d.h. du hast für die Zeit nicht den Bildschirm berührt)."
                        : "Bekomme die Abfrage immer, unabhängig von Bildschirm-Aktivität.",
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        // Navigation buttons
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: state.isEditingMode
                ? "Lerneinheit mit Änderungen starten"
                : "Lerneinheit sofort starten",
            onPressed: () => _startSession(state.isEditingMode),
          ),
        ),
        const VerticalSpace(size: SpaceSize.small),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: state.isEditingMode
                ? "Änderungen speichern"
                : "Lerneinheit erstellen",
            onPressed: () =>
                state.isEditingMode ? _updateSession() : _saveSession(),
          ),
        ),
      ],
    );
  }
}
