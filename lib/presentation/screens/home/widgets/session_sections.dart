import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/home/widgets/completed_tile.dart';
import 'package:srl_app/presentation/screens/home/widgets/pending_session_tile.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class SessionSectionSliver extends StatelessWidget {
  const SessionSectionSliver({
    required this.items,
    required this.emptyLabel,
    required this.itemBuilder,
    super.key,
    this.title,
  });
  final String? title;
  final List<SessionWithInstanceModel> items;
  final String emptyLabel;
  final Widget Function(SessionWithInstanceModel) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Text(emptyLabel, style: context.textTheme.bodyMedium),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        if (title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title!, style: context.textTheme.labelMedium),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => itemBuilder(items[index]),
            childCount: items.length,
          ),
        ),
      ],
    );
  }
}

class ButtonAction extends ConsumerWidget {
  const ButtonAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );

    final activeSessions = ref.watch(
      sessionsForDateProvider(selectedDate),
    );

    final completedSessions = ref.watch(
      completedSessionsForDateProvider(selectedDate),
    );

    // Combine both states; ONLY if both are empty, show the button
    return activeSessions.when(
      data: (activeList) {
        return completedSessions.when(
          data: (completedList) {
            if (activeList.isEmpty && completedList.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VerticalSpace(),
                  CustomIconButton(
                    radius: 10,
                    isActive: true,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.addSession,
                      arguments: AddSessionArgs(fromHomeScreen: true),
                    ),
                    label: 'Füge eine neue Lerneinheit hinzu',
                    icon: const Icon(Icons.add_box_outlined),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Section for all active sessions
class HomeSectionActive extends ConsumerWidget {
  const HomeSectionActive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );

    final activeSessions = ref.watch(
      sessionsForDateProvider(selectedDate),
    );
    final isAllFilter = ref.watch(
      homeViewModelProvider.select((s) => s.filter == SessionFilter.all),
    );

    return activeSessions.when(
      data: (List<SessionWithInstanceModel> data) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SessionSectionSliver(
            title: isAllFilter ? 'Anstehende Lerneinheiten' : null,
            items: data,
            emptyLabel: 'Keine offene Lerneinheit',
            itemBuilder: (data) => PendingSessionTile(
              session: data.session,
              pendingInstance: data.instance,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Fehler: $err')),
    );
  }
}

/// Section for all completed sessions
class HomeSectionCompleted extends ConsumerWidget {
  const HomeSectionCompleted({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );

    final completedSessions = ref.watch(
      completedSessionsForDateProvider(selectedDate),
    );
    final isAllFilter = ref.watch(
      homeViewModelProvider.select(
        (s) => s.filter == SessionFilter.all || s.filter == SessionFilter.done,
      ),
    );

    return completedSessions.when(
      data: (List<SessionWithInstanceModel> data) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SessionSectionSliver(
            title: isAllFilter ? 'Erledigte Lerneinheiten' : null,
            items: data,
            emptyLabel: 'Keine Lerneinheiten erledigt',
            itemBuilder: (data) => CompletedSessionTile(
              sessionWithInstance: data,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Fehler: $err')),
    );
  }
}

/// Section for all skipped sessions
class HomeSectionSkipped extends ConsumerWidget {
  const HomeSectionSkipped({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );

    final completedSessions = ref.watch(
      completedSessionsForDateProvider(selectedDate),
    );

    final filter = ref.watch(
      homeViewModelProvider.select(
        (s) =>
            s.filter == SessionFilter.all || s.filter == SessionFilter.skipped,
      ),
    );

    return completedSessions.when(
      data: (List<SessionWithInstanceModel> data) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SessionSectionSliver(
            title: filter ? 'Übersprungene Lerneinheiten' : null,
            items: data.where((session) => session.isSkipped).toList(),
            emptyLabel: 'Keine Lerneinheiten übersprungen',
            itemBuilder: (data) => CompletedSessionTile(
              sessionWithInstance: data,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Fehler: $err')),
    );
  }
}
