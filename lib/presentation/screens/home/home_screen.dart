import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/custom_filter_chip.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/home/widgets/calendar_widget.dart';
import 'package:srl_app/presentation/screens/home/widgets/completed_tile.dart';
import 'package:srl_app/presentation/screens/home/widgets/pending_session_tile.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _$HomeScreenState();
}

class _$HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    if (homeState.isLoading) return const LoadingIndicator();

    if (homeState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ups, da ist etwas schiefgelaufen.'),
              TextButton(
                onPressed: () =>
                    ref.read(homeViewModelProvider.notifier).refresh(),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeading(context),

              const VerticalSpace(),

              const CalendarWidget(),

              const VerticalSpace(),

              _buildProgressBar(homeState),

              const VerticalSpace(),

              // Filter buttons
              Wrap(
                spacing: 8,
                children: <Widget>[
                  CustomFilterChip(
                    label: 'Alle',
                    isActive: homeState.filter == SessionFilter.all,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.all),
                  ),
                  CustomFilterChip(
                    label: 'Offen',
                    isActive: homeState.filter == SessionFilter.open,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.open),
                  ),
                  CustomFilterChip(
                    label: 'Übersprungen',
                    isActive: homeState.filter == SessionFilter.skipped,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.skipped),
                  ),
                  CustomFilterChip(
                    label: 'Erledigt',
                    isActive: homeState.filter == SessionFilter.done,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.done),
                  ),
                ],
              ),

              const VerticalSpace(),

              // List of completed sessions
              if (homeState.filter == SessionFilter.all ||
                  homeState.filter == SessionFilter.open)
                _SessionSection(
                  title: homeState.filter == SessionFilter.all
                      ? 'Anstehende Lerneinheiten'
                      : null,
                  items: homeState.todaysSessions,
                  emptyLabel: 'Keine Lerneinheiten mehr offen',
                  itemBuilder: (data) => PendingSessionTile(
                    session: data.session,
                    hasInstance: data.instance != null,
                  ),
                ),

              if (homeState.filter == SessionFilter.all ||
                  homeState.filter == SessionFilter.done)
                _SessionSection(
                  title: homeState.filter != SessionFilter.done
                      ? 'Erledigte Lerneinheiten'
                      : null,
                  items: homeState.completedSessionsForToday,
                  emptyLabel: 'Noch nichts erledigt',
                  itemBuilder: (data) =>
                      CompletedSessionTile(sessionWithInstance: data),
                ),

              if (homeState.filter == SessionFilter.skipped)
                _SessionSection(
                  title: homeState.filter != SessionFilter.skipped
                      ? 'Übersprungene Lerneinheiten'
                      : null,
                  items: homeState.skippedSessionsForToday,
                  emptyLabel: 'Noch keine Lerneinheiten heute übersprungen',
                  itemBuilder: (data) => PendingSessionTile(
                    session: data.session,
                    hasInstance: data.instance != null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(HomeState homeState) {
    String getMotivationalSubtext() {
      final remaining = homeState.todaysSessions.length;
      if (remaining == 0 && homeState.completedSessionsForToday.isNotEmpty) {
        return 'Du hast alles erledigt! Zeit zum Entspannen. ✨';
      }
      if (remaining > 0) {
        return 'Du hast heute noch $remaining Einheiten vor dir.';
      }
      return 'Bereit für deine erste Einheit?';
    }

    final total =
        homeState.todaysSessions.length +
        homeState.completedSessionsForToday.length;

    final percent = total > 0
        ? (homeState.completedSessionsForToday.length / total)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tagesziel',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
        const VerticalSpace(size: SpaceSize.xsmall),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: AppPalette.grey.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colorScheme.primary,
            ),
          ),
        ),
        const VerticalSpace(
          size: SpaceSize.small,
        ),
        Text(
          getMotivationalSubtext(),
          style: context.textTheme.bodyMedium!.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHeading(BuildContext context) {
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Morgen ☀️';
      if (hour < 15) return 'Tag ⛅️';
      if (hour < 18) return 'Nachmittag ⛅️';
      return 'Abend 🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Guten ',
              style: context.textTheme.headlineLarge!.copyWith(
                fontSize: 26,
              ),
            ),
            Text(
              getGreeting(),
              style: context.textTheme.headlineLarge!.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ),
          ],
        ),

        Text(
          DateFormat('EEEE, d. MMMM', 'de_DE').format(DateTime.now()),
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SessionSection extends StatelessWidget {
  const _SessionSection({
    required this.title,
    required this.items,
    required this.emptyLabel,
    required this.itemBuilder,
  });
  final String? title;
  final List<SessionWithInstanceModel> items;
  final String emptyLabel;
  final Widget Function(SessionWithInstanceModel) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: context.textTheme.labelMedium!.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        const VerticalSpace(size: SpaceSize.xsmall),
        if (items.isEmpty)
          Text(
            emptyLabel,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          )
        else
          ...items.map(
            itemBuilder,
          ),
        const VerticalSpace(),
      ],
    );
  }
}
