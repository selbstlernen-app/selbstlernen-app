import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/data/test_data.dart';
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
      return Scaffold(body: Center(child: Text('Error: ${homeState.error}')));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeading(context),

              // TODO: remove for production
              // ElevatedButton(
              //   onPressed: () async {
              //     await ref.read(testDataProvider.notifier).insertTestData();
              //   },
              //   child: const Text('Insert Test Data'),
              // ),
              const VerticalSpace(),

              const CalendarWidget(),

              const VerticalSpace(),

              Wrap(
                spacing: 8,
                children: <Widget>[
                  CustomButton(
                    verticalPadding: 2,
                    borderRadius: 10,
                    isActive: homeState.filter == SessionFilter.all,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.all),
                    label: 'Alle',
                  ),
                  CustomButton(
                    verticalPadding: 4,
                    borderRadius: 10,
                    isActive: homeState.filter == SessionFilter.open,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.open),
                    label: 'Offen',
                  ),
                  CustomButton(
                    verticalPadding: 4,
                    borderRadius: 10,
                    isActive: homeState.filter == SessionFilter.skipped,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.skipped),
                    label: 'Übersprungen',
                  ),
                  CustomButton(
                    verticalPadding: 4,
                    borderRadius: 10,
                    isActive: homeState.filter == SessionFilter.done,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.done),
                    label: 'Erledigt',
                  ),
                ],
              ),

              const VerticalSpace(size: SpaceSize.small),

              // List todays open sessions
              if (homeState.filter == SessionFilter.open ||
                  homeState.filter == SessionFilter.all) ...[
                Text(
                  'Anstehende Lerneinheiten',
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppPalette.grey,
                  ),
                ),
                if (homeState.todaysSessions.isNotEmpty) ...[
                  const VerticalSpace(),
                  ...homeState.todaysSessions.map(
                    (SessionWithInstanceModel sessionWithInstance) =>
                        PendingSessionTile(
                          session: sessionWithInstance.session,
                          hasInstance: sessionWithInstance.instance != null,
                        ),
                  ),
                  const VerticalSpace(),
                ],
                if (homeState.todaysSessions.isEmpty) ...[
                  const VerticalSpace(
                    size: SpaceSize.xsmall,
                  ),
                  Text(
                    'Keine Lerneinheiten mehr offen für heute',
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: AppPalette.grey.withValues(alpha: 0.8),
                    ),
                  ),
                  const VerticalSpace(),
                ],
              ],

              // List of completed sessions
              if (homeState.filter == SessionFilter.done ||
                  homeState.filter == SessionFilter.all) ...[
                Text(
                  'Erledigte Lerneinheiten',
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppPalette.grey,
                  ),
                ),
                if (homeState.completedSessionsForToday.isNotEmpty) ...[
                  const VerticalSpace(),
                  ...homeState.completedSessionsForToday.map(
                    (SessionWithInstanceModel sessionWithInstance) =>
                        CompletedSessionTile(
                          sessionWithInstance: sessionWithInstance,
                        ),
                  ),
                  const VerticalSpace(),
                ],
                if (homeState.completedSessionsForToday.isEmpty) ...[
                  const VerticalSpace(
                    size: SpaceSize.xsmall,
                  ),
                  Text(
                    'Noch keine Lerneinheiten für heute erledigt',
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: AppPalette.grey.withValues(alpha: 0.8),
                    ),
                  ),
                  const VerticalSpace(),
                ],
              ],

              // List of skipped sessions
              if (homeState.filter == SessionFilter.skipped) ...[
                Text(
                  'Übersprungen',
                  style: context.textTheme.labelLarge!.copyWith(
                    color: AppPalette.grey,
                  ),
                ),
                if (homeState.skippedSessionsForToday.isNotEmpty) ...[
                  const VerticalSpace(),
                  ...homeState.skippedSessionsForToday.map(
                    (SessionWithInstanceModel sessionWithInstance) =>
                        CompletedSessionTile(
                          sessionWithInstance: sessionWithInstance,
                        ),
                  ),
                ],
                if (homeState.skippedSessionsForToday.isEmpty) ...[
                  const VerticalSpace(size: SpaceSize.xsmall),
                  Text(
                    'Keine übersprungenen Lerneinheiten für heute',
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: AppPalette.grey.withValues(alpha: 0.8),
                    ),
                  ),
                  const VerticalSpace(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Morgen ☀️';
    if (hour < 15) return 'Tag ⛅️';
    if (hour < 18) return 'Nachmittag ⛅️';
    return 'Abend 🌙';
  }

  String _getSubHeading() {
    final now = DateTime.now();
    return DateFormat('EEEE, d. MMMM', 'de_DE').format(now);
  }

  Widget _buildHeading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Guten ',
              style: context.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ),
            Text(
              _getGreeting(),
              style: context.textTheme.titleLarge!.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ),
          ],
        ),

        Text(
          _getSubHeading(),
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
