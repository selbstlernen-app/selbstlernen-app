import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/time_break_down_item.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_view_model.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    this.instanceId,
  });
  final int sessionId;
  final int? instanceId;

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
        if (detailState.fullSession == null) {
          return const Scaffold(
            body: Center(child: Text('Session nicht gefunden')),
          );
        }

        final SessionModel session = detailState.fullSession!.session;

        return MainLayout(
          navigateBack: () {
            Navigator.of(context).pop();
          },
          appBarTitle: session.title,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addSession,
                  arguments: detailState.fullSession,
                );
              },
              icon: const Icon(Icons.mode_edit_outline_rounded),
            ),
            IconButton(
              onPressed: () async {
                await deleteSessionDialog(context, session.isRepeating, ref);
              },
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Einzelheiten zu dieser Lerneinheit",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.medium),

                      Text("Ziele", style: context.textTheme.headlineSmall),
                      const VerticalSpace(size: SpaceSize.xsmall),
                      ...detailState.fullSession!.goals.map((GoalModel goal) {
                        return CustomItemTile(
                          text: goal.title,
                          isLargeGoal: true,
                        );
                      }),
                      if (detailState
                          .fullSession!
                          .ungroupedTasks
                          .isNotEmpty) ...<Widget>[
                        const VerticalSpace(size: SpaceSize.medium),
                        Text(
                          "Sonstige Aufgaben",
                          style: context.textTheme.headlineSmall,
                        ),
                        const VerticalSpace(size: SpaceSize.xsmall),
                        ...detailState.fullSession!.ungroupedTasks.map((
                          TaskModel task,
                        ) {
                          return CustomItemTile(
                            text: task.title,
                            isLargeGoal: false,
                          );
                        }),
                      ],

                      const VerticalSpace(size: SpaceSize.large),

                      Text(
                        "Deine Strategien",
                        style: context.textTheme.headlineSmall,
                      ),
                      const VerticalSpace(size: SpaceSize.xsmall),
                      Text(session.learningStrategies.toString()),

                      const VerticalSpace(size: SpaceSize.large),

                      Text(
                        "Geplante Zeit",
                        style: context.textTheme.headlineSmall,
                      ),
                      const VerticalSpace(size: SpaceSize.xsmall),

                      Column(
                        children: <Widget>[
                          TimeBreakdownItem(
                            icon: Icons.psychology,
                            label: 'Fokuszeit',
                            value:
                                '${TimeUtils.formatTime(session.focusTimeMin * 60)} Min',
                            color: AppPalette.pink,
                          ),

                          TimeBreakdownItem(
                            icon: Icons.coffee,
                            label: 'Pausenzeit',
                            value:
                                '${TimeUtils.formatTime(session.breakTimeMin * 60)} Min',
                            color: AppPalette.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (instanceId != null) ...<Widget>[
                Text(
                  "Einheit für heute erledigt!",
                  style: context.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const VerticalSpace(size: SpaceSize.medium),
                SizedBox(
                  width: context.mediaQuery.size.width,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.stats, arguments: sessionId);
                    },
                    label: "Zur statistischen Auswertung",
                  ),
                ),
              ],

              if (instanceId == null)
                SizedBox(
                  width: context.mediaQuery.size.width,
                  child: CustomButton(
                    onPressed: () async {
                      try {
                        // Get or create instance
                        SessionInstanceModel existingInstance = await ref
                            .read(
                              detailSessionViewModelProvider(
                                sessionId,
                              ).notifier,
                            )
                            .startSession(DateTime.now());

                        if (context.mounted) {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.active,
                            arguments: ActiveSessionArgs(
                              instanceId: int.parse(existingInstance.id!),
                              sessionId: int.parse(session.id!),
                            ),
                          );
                        }
                      } catch (e) {
                        throw ArgumentError(e);
                      }
                    },
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
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(Constants.successDeleted),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
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
