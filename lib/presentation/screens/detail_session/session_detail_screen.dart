import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/screens/active_session/active_session_screen.dart';
import 'package:srl_app/presentation/screens/add_session/add_session_screen.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_view_model.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DetailSessionState> state = ref.watch(
      detailSessionViewModelProvider(sessionId),
    );

    return state.when(
      loading: () => const LoadingIndicator(),
      error: (Object error, StackTrace stack) =>
          Center(child: Text('Error: $error')),
      data: (DetailSessionState detailState) {
        final SessionModel session = detailState.fullSession.session;
        return MainLayout(
          navigateBack: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => const MainNavigation(),
              ),
              (Route<dynamic> route) => false,
            );
          },
          appBarTitle: session.title,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => AddSessionScreen(
                      fullSessionModel: detailState.fullSession,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.mode_edit_outline_rounded),
            ),
            IconButton(
              onPressed: () async {
                await deleteSessionDialog(
                  context,
                  detailState.fullSession.session.isRepeating,
                  ref,
                );
              },
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Deine Ziele für diese Einheit",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      ...detailState.fullSession.goals.map((GoalModel goal) {
                        return Row(
                          children: <Widget>[
                            Text(
                              "🏁",
                              style: context.textTheme.bodyLarge!.copyWith(
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              goal.title,
                              style: context.textTheme.bodyLarge,
                            ),
                          ],
                        );
                      }),

                      const VerticalSpace(size: SpaceSize.large),

                      Text(
                        "Deine Strategien",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      Text(session.learningStrategies.toString()),

                      const VerticalSpace(size: SpaceSize.large),

                      Text(
                        "Geplante Zeit",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      Text(session.focusTimeMin.toString()),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: context.mediaQuery.size.width,
                child: CustomButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => ActiveSessionScreen(
                        fullSessionModel: detailState.fullSession,
                      ),
                    ),
                  ),
                  label: "Starten",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteSessionDialog(
    BuildContext context,
    bool isRepeating,
    WidgetRef ref,
  ) {
    void deleteSession() {
      ref
          .read(detailSessionViewModelProvider(sessionId).notifier)
          .deleteSession();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Lerneinheit erfolgreich gelöscht!"),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const MainNavigation(),
        ),
        (Route<dynamic> route) => false,
      );
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Lerneinheit löschen',
            style: context.textTheme.headlineMedium,
          ),
          content: Text(
            isRepeating
                ? 'Willst du diese und alle zukünftigen Einheiten löschen?'
                : "Willst du diese Einheit wirklich löschen?",
            style: context.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                overlayColor: context.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Abbrechen",
                style: context.textTheme.labelLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: () => deleteSession(),
              child: const Text("Bestätigen"),
            ),
          ],
        );
      },
    );
  }
}
