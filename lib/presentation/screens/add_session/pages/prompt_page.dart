import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class PromptPage extends ConsumerStatefulWidget {
  const PromptPage({super.key, required this.navigateForward});
  final VoidCallback navigateForward;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _$PromptPageState();
}

class _$PromptPageState extends ConsumerState<PromptPage> {
  void _switchValues({bool? focus, bool? mood, bool? freetext}) {
    ref
        .read(addSessionViewModelProvider.notifier)
        .setPrompts(focus: focus, mood: mood, freetext: freetext);
  }

  void _saveSession() {
    try {
      ref.read(addSessionViewModelProvider.notifier).createSession();
      context.scaffoldMessenger.showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Einheit erfolgreich gespeichert!"),
        ),
      );
      Navigator.of(context).pushNamed("/");
    } catch (e) {
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
                  "Prompter auswählen",
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.large),

                Text("Fokusabfrage", style: context.textTheme.headlineSmall),
                const VerticalSpace(size: SpaceSize.small),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Alle 15 min wirst du abgefragt, ob du noch aufmerksam bist.",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: state.hasFocusPrompt,
                      onChanged: (bool value) {
                        _switchValues(focus: value);
                      },
                    ),
                  ],
                ),

                const VerticalSpace(size: SpaceSize.large),

                Text(
                  "Stimmungsabfrage ",
                  style: context.textTheme.headlineSmall,
                ),
                const VerticalSpace(size: SpaceSize.small),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Nach einer Lerneinheit wirst du abefragt, wie du dich gefühlt hast.",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: state.hasMoodPrompt,
                      onChanged: (bool value) {
                        _switchValues(mood: value);
                      },
                    ),
                  ],
                ),

                const VerticalSpace(size: SpaceSize.large),

                Text(
                  "Notizen abspeichern",
                  style: context.textTheme.headlineSmall,
                ),
                const VerticalSpace(size: SpaceSize.small),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Nach einer Lerneinheit kannst du in einem Freitextfeld Notizen abspeichern.",
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: state.hasFreetextPrompt,
                      onChanged: (bool value) {
                        _switchValues(freetext: value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Navigation buttons
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: "Lerneinheit sofort starten",
            onPressed: () => print("start"),
          ),
        ),
        const VerticalSpace(size: SpaceSize.large),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: "Lerneinheit erstellen",
            onPressed: () => _saveSession(),
          ),
        ),
      ],
    );
  }
}
