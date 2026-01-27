import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/custom_filter_chip.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/home/widgets/calendar_widget.dart';
import 'package:srl_app/presentation/screens/home/widgets/session_sections.dart';
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
    final filter = ref.watch(homeViewModelProvider.select((s) => s.filter));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Greeting(),
                    VerticalSpace(),
                    CalendarWidget(),
                    VerticalSpace(),
                    ProgressBar(),
                    VerticalSpace(),
                    FilterButtonRow(),
                  ],
                ),
              ),
            ),

            // Dynamic Sections
            if (filter == SessionFilter.all ||
                filter == SessionFilter.open) ...[
              const HomeSectionActive(),
              const SliverToBoxAdapter(
                child: VerticalSpace(
                  size: SpaceSize.xsmall,
                ),
              ),
            ],

            if (filter == SessionFilter.all || filter == SessionFilter.done)
              const HomeSectionCompleted(),

            if (filter == SessionFilter.skipped) const HomeSectionSkipped(),

            const SliverToBoxAdapter(
              child: VerticalSpace(size: SpaceSize.large),
            ),
          ],
        ),
      ),
    );
  }
}

class Greeting extends ConsumerWidget {
  const Greeting({super.key});

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morgen ☀️';
    if (hour < 15) return 'Tag ⛅️';
    if (hour < 18) return 'Nachmittag ⛅️';
    return 'Abend 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class FilterButtonRow extends ConsumerWidget {
  const FilterButtonRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(
      homeViewModelProvider.select((s) => s.filter),
    );

    return Wrap(
      spacing: 8,
      children: <Widget>[
        CustomFilterChip(
          label: 'Alle',
          isActive: filter == SessionFilter.all,
          onPressed: () => ref
              .read(homeViewModelProvider.notifier)
              .setFilter(SessionFilter.all),
        ),
        CustomFilterChip(
          label: 'Offen',
          isActive: filter == SessionFilter.open,
          onPressed: () => ref
              .read(homeViewModelProvider.notifier)
              .setFilter(SessionFilter.open),
        ),
        CustomFilterChip(
          label: 'Übersprungen',
          isActive: filter == SessionFilter.skipped,
          onPressed: () => ref
              .read(homeViewModelProvider.notifier)
              .setFilter(SessionFilter.skipped),
        ),
        CustomFilterChip(
          label: 'Erledigt',
          isActive: filter == SessionFilter.done,
          onPressed: () => ref
              .read(homeViewModelProvider.notifier)
              .setFilter(SessionFilter.done),
        ),
      ],
    );
  }
}

class ProgressBar extends ConsumerWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );
    final activeSessions =
        ref.watch(sessionsForDateProvider(selectedDate)).value ?? [];
    final completedSessions =
        ref
            .watch(
              completedSessionsForDateProvider(selectedDate),
            )
            .value ??
        [];

    final total = activeSessions.length + completedSessions.length;

    final percent = total > 0 ? (completedSessions.length / total) : 0.0;

    String getMotivationalSubtext() {
      final remaining = activeSessions.length;
      if (remaining == 0 && completedSessions.isNotEmpty) {
        return 'Du hast alles erledigt! Zeit zum Entspannen. ✨';
      }
      if (remaining > 0) {
        return 'Du hast heute noch $remaining Einheiten vor dir.';
      }
      return 'Bereit für deine erste Einheit?';
    }

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
}
