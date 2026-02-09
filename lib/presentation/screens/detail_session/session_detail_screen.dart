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

    if (state.isLoading) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }
    if (state.hasError || !state.hasSession) {
      return Scaffold(
        body: Center(
          child: Text(
            state.hasError
                ? 'Fehler: ${state.error}'
                : 'Lerneinheit nicht gefunden',
          ),
        ),
      );
    }

    final session = state.session!;
    final instance = state.instance;
    final goals = state.goals;
    final ungroupedTasks = state.fullSession!.ungroupedTasks;

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
                    _StrategiesSection(strategies: session.learningStrategies),

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
                      final useCase = ref.read(manangeInstanceUseCaseProvider);
                      await useCase.deleteInstanceById(instanceId!);
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
                      final useCase = ref.read(manageSessionUseCaseProvider);
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
            SizedBox(
              width: double.infinity,
              child: CustomIconButton(
                isActive: true,
                icon: const Icon(Icons.redo),
                label: 'Wiederholen?',
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
          icon: Icons.psychology,
          label: 'Fokuszeit',
          value: '${TimeUtils.formatTime(session.focusTimeMin * 60)} Min',
          color: AppPalette.pink,
        ),

        // Actual focus time (if instance exists)
        if (instance != null) ...[
          TimeBreakdownItem(
            icon: Icons.psychology,
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
            icon: Icons.coffee,
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
              label: 'Gesamte Zeit',
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

class _StrategiesSection extends StatelessWidget {
  const _StrategiesSection({required this.strategies});

  final List<String> strategies;

  @override
  Widget build(BuildContext context) {
    if (strategies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deine Strategien', style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.small),
        ...strategies.map(Text.new),
        const VerticalSpace(size: SpaceSize.large),
      ],
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
