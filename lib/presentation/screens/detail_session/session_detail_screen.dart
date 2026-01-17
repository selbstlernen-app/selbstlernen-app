import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/common_widgets/time_break_down_item.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_view_model.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({
    required this.sessionId,
    super.key,
    this.instanceId,
  });
  final int sessionId;
  final int? instanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      detailSessionViewModelProvider(sessionId, instanceId: instanceId),
    );

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    final session = state.fullSession!.session;
    final instance = state.instance;

    return MainLayout(
      navigateBack: () {
        Navigator.of(context).pop();
      },
      appBarTitle: session.title,
      actions: <Widget>[
        if (!session.isArchived)
          CustomIconButton(
            isActive: true,
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.addSession,
                arguments: state.fullSession,
              );
            },
            icon: const Icon(Icons.mode_edit_outline_rounded),
          ),
      ],
      content: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (session.isArchived) ...[
                    Text(
                      'Diese Einheit ist archiviert',
                      style: context.textTheme.headlineSmall!.copyWith(
                        color: AppPalette.orange,
                      ),
                    ),
                    const VerticalSpace(
                      size: SpaceSize.small,
                    ),
                  ],
                  // If session was checked off for today, say so in title
                  if (instanceId != null && !session.isArchived) ...<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🥳',
                          style: TextStyle(fontSize: 36),
                        ),
                        const HorizontalSpace(size: SpaceSize.small),
                        Text(
                          'Einheit für heute erledigt!',
                          style: context.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const VerticalSpace(
                      size: SpaceSize.large,
                    ),
                  ],

                  // Planned work and break time
                  Text(
                    'Geplante Zeit',
                    style: context.textTheme.headlineSmall,
                  ),
                  const VerticalSpace(size: SpaceSize.small),
                  Column(
                    children: <Widget>[
                      TimeBreakdownItem(
                        icon: Icons.psychology,
                        label: 'Fokuszeit',
                        value:
                            '''${TimeUtils.formatTime(session.focusTimeMin * 60)} Min''',
                        color: AppPalette.pink,
                      ),

                      if (instanceId != null && instance != null) ...[
                        TimeBreakdownItem(
                          icon: Icons.psychology,
                          label: 'Durchgeführte Fokuszeit',
                          value:
                              '''${TimeUtils.formatTime(instance.totalFocusSecondsElapsed)} Min''',
                          color: AppPalette.pinkLight,
                        ),
                        const VerticalSpace(),
                      ],

                      if (!session.hasSimpleTimer)
                        TimeBreakdownItem(
                          icon: Icons.coffee,
                          label: 'Pausenzeit',
                          value:
                              '''${TimeUtils.formatTime(session.breakTimeMin * 60)} Min''',
                          color: AppPalette.orange,
                        ),

                      if (instanceId != null &&
                          instance != null &&
                          !session.hasSimpleTimer) ...[
                        TimeBreakdownItem(
                          icon: Icons.coffee,
                          label: 'Durchgeführte Pausenzeit',
                          value:
                              '''${TimeUtils.formatTime(instance.totalBreakSecondsElapsed)} Min''',
                          color: AppPalette.orangeLight,
                        ),

                        const VerticalSpace(size: SpaceSize.small),
                        Divider(
                          color: context.colorScheme.tertiary,
                          thickness: 4,
                          radius: BorderRadius.circular(10),
                        ),
                        const VerticalSpace(size: SpaceSize.small),

                        TimeBreakdownItem(
                          icon: Icons.timelapse_outlined,
                          label: 'Gesamte Zeit',
                          value:
                              '''${TimeUtils.formatTime(instance.totalBreakSecondsElapsed + instance.totalFocusSecondsElapsed)} Min''',
                          color: AppPalette.sky,
                        ),
                      ],
                    ],
                  ),

                  const VerticalSpace(size: SpaceSize.large),

                  // Planned strategies
                  if (instanceId == null) ...[
                    Text(
                      'Deine Strategien',
                      style: context.textTheme.headlineSmall,
                    ),
                    const VerticalSpace(size: SpaceSize.small),
                    ...session.learningStrategies.map(
                      Text.new,
                    ),
                    const VerticalSpace(size: SpaceSize.large),
                  ],

                  // Goals and tasks column
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (state.fullSession!.goals.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ...<Widget>[
                                Text(
                                  'Ziele',
                                  style: context.textTheme.headlineSmall,
                                ),
                                const VerticalSpace(size: SpaceSize.small),
                                ...state.fullSession!.goals.map((
                                  GoalModel goal,
                                ) {
                                  return CustomItemTile(
                                    iconSize: 20,
                                    text: goal.title,
                                    isLargeGoal: true,
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      if (state.fullSession!.ungroupedTasks.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ...<Widget>[
                                Text(
                                  'Sonstige Aufgaben',
                                  style: context.textTheme.headlineSmall,
                                ),
                                const VerticalSpace(size: SpaceSize.small),
                                ...state.fullSession!.ungroupedTasks.map((
                                  TaskModel task,
                                ) {
                                  return CustomItemTile(
                                    iconSize: 20,
                                    text: task.title,
                                    isLargeGoal: false,
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete and archive buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Delete the current instance
              if (instanceId != null)
                IconButton(
                  onPressed: () async {
                    await deleteInstanceDialog(
                      context,
                      ref,
                      instanceId: instanceId!,
                    );
                  },
                  icon: const Icon(Icons.delete_forever),
                ),

              IconButton(
                color: AppPalette.rose,
                onPressed: () async {
                  await deleteSessionDialog(
                    context,
                    ref,
                    isRepeating: session.isRepeating,
                  );
                },
                icon: const Icon(Icons.delete_sweep_rounded),
              ),

              // If the session has more than 1 item
              // Able to archive it
              if (!session.isArchived && state.pastInstancesLength! > 0)
                IconButton(
                  color: AppPalette.orange,
                  onPressed: () async {
                    await archiveSessionDialog(
                      context,
                      ref,
                      isRepeating: session.isRepeating,
                    );
                  },
                  icon: const Icon(Icons.archive_outlined),
                ),
            ],
          ),

          // Repeat button
          if (instanceId != null)
            SizedBox(
              width: context.mediaQuery.size.width,
              child: CustomIconButton(
                verticalPadding: 16,
                radius: 30,
                isActive: true,
                icon: const Icon(Icons.redo),
                onPressed: () async {
                  try {
                    // Create new instance
                    final newInstance = await ref
                        .read(
                          detailSessionViewModelProvider(
                            sessionId,
                          ).notifier,
                        )
                        .redoSession();

                    if (context.mounted) {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.active,
                        arguments: ActiveSessionArgs(
                          instanceId: int.parse(newInstance.id!),
                          sessionId: int.parse(session.id!),
                        ),
                      );
                    }
                  } on Exception catch (e) {
                    throw ArgumentError(e);
                  }
                },
                label: 'Wiederholen?',
              ),
            ),

          if (instanceId != null) ...<Widget>[
            const VerticalSpace(
              size: SpaceSize.xsmall,
            ),
            SizedBox(
              width: context.mediaQuery.size.width,
              child: CustomButton(
                onPressed: () async {
                  await Navigator.of(
                    context,
                  ).pushNamed(
                    AppRoutes.stats,
                    arguments: SessionStatisticsArgs(
                      sessionId: sessionId,
                      showGeneralStatsOnly: false,
                    ),
                  );
                },
                label: 'Zur statistischen Auswertung',
              ),
            ),
          ],

          if (instanceId == null && !session.isArchived)
            SizedBox(
              width: context.mediaQuery.size.width,
              child: CustomButton(
                onPressed: () async {
                  try {
                    // Get or create instance
                    final existingInstance = await ref
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
                  } on Exception catch (e) {
                    throw ArgumentError(e);
                  }
                },
                label: 'Starten',
              ),
            ),
        ],
      ),
    );
  }

  // Dialogs
  Future<void> deleteSessionDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool isRepeating,
  }) {
    Future<void> deleteSession() async {
      await ref
          .read(detailSessionViewModelProvider(sessionId).notifier)
          .deleteSession();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(Constants.successDeleted),
          ),
        );
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (Route<dynamic> route) => false,
        );
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Lerneinheit löschen?',
            style: context.textTheme.headlineMedium,
          ),
          content: Text(
            '''Wenn du diese Einheit löschst, löschst du auch alle bisher durchgeführten Instanzen und Daten.\nDies kannst du nicht mehr rückgängig machen.'''
            '''${isRepeating ? 'Willst du diese und alle zukünftigen Einheiten löschen?' : 'Willst du diese Einheit wirklich löschen?'}''',

            style: context.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                overlayColor: context.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Abbrechen',
                style: context.textTheme.labelLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: deleteSession,
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteInstanceDialog(
    BuildContext context,
    WidgetRef ref, {
    required int instanceId,
  }) {
    Future<void> deleteInstance() async {
      await ref
          .read(detailSessionViewModelProvider(sessionId).notifier)
          .deleteInstance(instanceId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(Constants.successDeleted),
          ),
        );
        await Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (Route<dynamic> route) => false,
        );
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Durchgeführte Einheit löschen?',
            style: context.textTheme.headlineMedium,
          ),
          content: Text(
            '''Willst du diese durchgeführte Lerneinheit löschen? Hiermit löschst du alle Daten, die in dieser Instanz erhoben worden sind.\nDies kannst du nicht mehr rückgängig machen.''',
            style: context.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                overlayColor: context.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Abbrechen',
                style: context.textTheme.labelLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: deleteInstance,
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }

  /// Dialog to archive a session
  Future<void> archiveSessionDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool isRepeating,
  }) {
    Future<void> archiveSession() async {
      await ref
          .read(detailSessionViewModelProvider(sessionId).notifier)
          .archiveSession();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 2),
            content: Text('Einheit erfolgreich archiviert'),
          ),
        );
        // Close dialog
        Navigator.of(context).pop();
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Lerneinheit archivieren?',
            style: context.textTheme.headlineMedium,
          ),
          content: Text(
            '''Wenn du diese Einheit archivierst, wirst du sie nicht länger bearbeiten oder durchführen können.'''
            '''\nAlte abgeschlossene Einheiten können aber weiterhin eingesehen werden.''',
            style: context.textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                overlayColor: context.colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Abbrechen',
                style: context.textTheme.labelLarge!.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: archiveSession,
              child: const Text('Bestätigen'),
            ),
          ],
        );
      },
    );
  }
}
