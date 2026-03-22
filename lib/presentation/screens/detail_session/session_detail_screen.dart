import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/session_dialogs.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/common_widgets/time_break_down_item.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_view_model.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';
import 'package:srl_app/presentation/view_models/providers.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({
    required this.sessionId,
    required this.targetDate,
    this.instanceId,
    super.key,
  });
  final int sessionId;
  final int? instanceId;
  final DateTime targetDate;

  Future<void> _handleSessionAction(
    BuildContext context,
    WidgetRef ref,
    bool isRedo,
  ) async {
    final notifier = ref.read(
      detailSessionViewModelProvider(
        sessionId,
        targetDate: targetDate,
      ).notifier,
    );
    try {
      final instance = isRedo
          ? await notifier.redoSession()
          : await notifier.startSession(sessionId);

      if (instance == null) {
        if (context.mounted) {
          context.scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Es existiert bereits eine laufende Session für heute. '
                'Bitte schließe diese zuerst ab.',
              ),
            ),
          );
        }
        return;
      } else {
        if (context.mounted) {
          await Navigator.pushNamed(
            context,
            AppRoutes.active,
            arguments: ActiveSessionArgs(
              instanceId: int.parse(instance.id!),
              sessionId: sessionId,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    FullSessionModel fullSession,
  ) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.addSession,
      arguments: AddSessionArgs(fullSessionModel: fullSession),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      detailSessionViewModelProvider(
        sessionId,
        instanceId: instanceId,
        targetDate: targetDate,
      ),
    );

    return state.when(
      data: (state) {
        if (!state.hasSession) {
          return const Scaffold(
            body: Center(
              child: Text('Lerneinheit nicht gefunden'),
            ),
          );
        }

        final session = state.session!;
        final instance = state.instance;
        final goals = state.goals;
        final ungroupedTasks = state.fullSession!.ungroupedTasks;

        // Your normal UI here
        return MainLayout(
          navigateBack: () {
            Navigator.of(context).pop();
          },
          appBarTitle: session.title,
          actions: <Widget>[
            if (state.canArchive)
              CustomIconButton(
                isActive: true,
                icon: const Icon(Icons.mode_edit_outline_rounded),
                onPressed: () => _navigateToEdit(context, state.fullSession!),
              ),
          ],
          content: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (session.isArchived) _ArchivedBanner(),

                      if (state.hasInstance && !session.isArchived)
                        _CompletedBanner(),

                      _TimeSection(
                        session: session,
                        instance: instance,
                      ),

                      const VerticalSpace(size: SpaceSize.large),

                      if (!state.hasInstance)
                        _StrategiesSection(sessionId: int.parse(session.id!)),

                      const VerticalSpace(size: SpaceSize.large),

                      // Goals and tasks column
                      _GoalsAndTasksSection(
                        goals: goals,
                        ungroupedTasks: ungroupedTasks,
                      ),
                    ],
                  ),
                ),
              ),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete Instance button -> only when repeating session!
                  if (instanceId != null && session.isRepeating)
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () => SessionDialogs.showDeleteInstance(
                        context,
                        onConfirm: () async {
                          final useCase = ref.read(
                            manangeInstanceUseCaseProvider,
                          );
                          await useCase.deleteInstanceById(instanceId!);

                          ref.invalidate(sessionsForDateProvider(targetDate));

                          if (context.mounted) {
                            await Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.home);
                          }
                        },
                      ),
                    ),

                  // Delete session button -> shown whenever
                  IconButton(
                    color: AppPalette.rose,
                    icon: const Icon(Icons.delete_sweep_rounded),
                    onPressed: () => SessionDialogs.showDeleteSession(
                      context,
                      isRepeating: state.session!.isRepeating,
                      shouldNavigateHome: true,
                      onConfirm: () async {
                        final useCase = ref.read(fullSessionUseCaseProvider);
                        await useCase.deleteFullModel(sessionId);
                      },
                    ),
                  ),

                  if (state.canArchive && state.hasPastSessions)
                    IconButton(
                      color: AppPalette.orange,
                      icon: const Icon(Icons.archive_outlined),
                      onPressed: () => SessionDialogs.showArchive(
                        context,
                        onConfirm: () async {
                          final useCase = ref.read(
                            manageSessionUseCaseProvider,
                          );
                          final updated = state.fullSession!.session.copyWith(
                            isArchived: true,
                          );
                          await useCase.updateSession(
                            sessionId,
                            updated,
                          );
                        },
                      ),
                    ),
                ],
              ),

              if (state.hasInstance) ...[
                // One-time session should NOT be repeatable -> they are one-off
                if (!session.isArchived)
                  SizedBox(
                    width: double.infinity,
                    child: CustomIconButton(
                      isActive: true,
                      icon: const Icon(Icons.add_circle_outline),
                      label: 'Erneut durchführen',
                      onPressed: () => _handleSessionAction(context, ref, true),
                    ),
                  ),
                const VerticalSpace(size: SpaceSize.xsmall),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Zur statistischen Auswertung',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.stats,
                      arguments: SessionStatisticsArgs(
                        sessionId: sessionId,
                        showGeneralStatsOnly: false,
                      ),
                    ),
                  ),
                ),
              ] else if (instanceId == null && !state.session!.isArchived)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Starten',
                    onPressed: () => _handleSessionAction(context, ref, false),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Fehler: $error'),
        ),
      ),
    );
  }
}

class _ArchivedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diese Einheit ist archiviert',
          style: context.textTheme.headlineSmall!.copyWith(
            color: AppPalette.orange,
          ),
        ),
        const VerticalSpace(size: SpaceSize.small),
      ],
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🥳', style: TextStyle(fontSize: 36)),
            const HorizontalSpace(size: SpaceSize.small),
            Text(
              'Einheit für heute erledigt!',
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const VerticalSpace(size: SpaceSize.large),
      ],
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({
    required this.session,
    this.instance,
  });

  final SessionModel session;
  final SessionInstanceModel? instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Geplante Zeit', style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),

        // Planned focus time
        TimeBreakdownItem(
          icon: Icons.timer_outlined,
          label: 'Fokuszeit',
          value: '${TimeUtils.formatTime(session.focusTimeMin * 60)} Min',
          color: AppPalette.pink,
        ),

        // Actual focus time (if instance exists)
        if (instance != null) ...[
          TimeBreakdownItem(
            icon: Icons.timer_rounded,
            label: 'Durchgeführte Fokuszeit',
            value:
                '${TimeUtils.formatTime(instance!.totalFocusSecondsElapsed)} Min',
            color: AppPalette.pinkLight,
          ),
          const VerticalSpace(),
        ],

        // Break time if not simple timer
        if (!session.isSimple) ...[
          TimeBreakdownItem(
            icon: Icons.coffee_outlined,
            label: 'Pausenzeit',
            value: '${TimeUtils.formatTime(session.breakTimeMin * 60)} Min',
            color: AppPalette.orange,
          ),

          // Actual break time (if instance exists)
          if (instance != null) ...[
            TimeBreakdownItem(
              icon: Icons.coffee,
              label: 'Durchgeführte Pausenzeit',
              value:
                  '${TimeUtils.formatTime(instance!.totalBreakSecondsElapsed)} Min',
              color: AppPalette.orangeLight,
            ),
            const VerticalSpace(size: SpaceSize.small),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
            ),
            const VerticalSpace(size: SpaceSize.small),

            // Total time
            TimeBreakdownItem(
              icon: Icons.timelapse_outlined,
              label: 'Gesamtzeit',
              value:
                  '${TimeUtils.formatTime(instance!.totalBreakSecondsElapsed + instance!.totalFocusSecondsElapsed)} Min',
              color: AppPalette.sky,
            ),
          ],
        ],
      ],
    );
  }
}

class _StrategiesSection extends ConsumerWidget {
  const _StrategiesSection({required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategiesWithDetails = ref.watch(
      sessionStrategiesProvider(sessionId),
    );

    return strategiesWithDetails.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Fehler: $err'),
      data: (strategies) {
        if (strategies.isEmpty) {
          return const Text('Keine Strategien ausgewählt');
        }
        return Column(
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, size: 32),
                const HorizontalSpace(size: SpaceSize.small),

                Text(
                  'Ausgewählte Lernstrategien',
                  style: context.textTheme.headlineSmall,
                ),
              ],
            ),
            const VerticalSpace(
              size: SpaceSize.small,
            ),
            ...strategies.map((strategy) {
              return Card(
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy.title,
                        style: context.textTheme.labelMedium,
                      ),
                      const VerticalSpace(
                        size: SpaceSize.xsmall,
                      ),
                    ],
                  ),
                  subtitle: strategy.explanation != null
                      ? Text(
                          strategy.explanation!,
                          style: context.textTheme.bodySmall,
                        )
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _GoalsAndTasksSection extends StatelessWidget {
  const _GoalsAndTasksSection({
    required this.goals,
    required this.ungroupedTasks,
  });

  final List<GoalModel> goals;
  final List<TaskModel> ungroupedTasks;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty && ungroupedTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (goals.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ziele', style: context.textTheme.headlineSmall),
                const VerticalSpace(size: SpaceSize.small),
                ...goals.map(
                  (goal) => CustomItemTile(
                    iconSize: 20,
                    text: goal.title,
                    isLargeGoal: true,
                  ),
                ),
              ],
            ),
          ),
        if (ungroupedTasks.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sonstige Aufgaben',
                  style: context.textTheme.headlineSmall,
                ),
                const VerticalSpace(size: SpaceSize.small),
                ...ungroupedTasks.map(
                  (task) => CustomItemTile(
                    iconSize: 20,
                    text: task.title,
                    isLargeGoal: false,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
