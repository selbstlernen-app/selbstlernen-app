import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/presentation/screens/home/widgets/calendar_widget.dart';
import 'package:srl_app/presentation/screens/home/widgets/completed_tile.dart';
import 'package:srl_app/presentation/screens/home/widgets/pending_session_tile.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';
import 'package:vibration/vibration.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _$HomeScreenState();
}

class _$HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final HomeState homeState = ref.watch(homeViewModelProvider);

    if (homeState.isLoading) return const LoadingIndicator();

    if (homeState.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${homeState.error}')));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeading(context),

              // TODO: remove for production
              // ElevatedButton(
              //   onPressed: () async {
              //     await ref.read(testDataProvider.notifier).insertTestData();
              //   },
              //   child: Text("Insert Test Data"),
              // ),
              const VerticalSpace(size: SpaceSize.medium),

              const CalendarWidget(),

              const VerticalSpace(size: SpaceSize.medium),

              Text(
                "Anstehende Lerneinheiten",
                style: context.textTheme.headlineSmall,
              ),
              const VerticalSpace(size: SpaceSize.small),
              Wrap(
                spacing: 8.0,
                children: <Widget>[
                  CustomButton(
                    verticalPadding: 8.0,
                    borderRadius: 10.0,
                    isActive: homeState.filter == SessionFilter.today,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.today),
                    label: "Für heute",
                  ),
                  CustomButton(
                    verticalPadding: 8.0,
                    borderRadius: 10.0,
                    isActive: homeState.filter == SessionFilter.thisWeek,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.thisWeek),
                    label: "Diese Woche",
                  ),
                  CustomButton(
                    verticalPadding: 8.0,
                    borderRadius: 10.0,
                    isActive: homeState.filter == SessionFilter.all,
                    onPressed: () => ref
                        .read(homeViewModelProvider.notifier)
                        .setFilter(SessionFilter.all),
                    label: "Alle",
                  ),
                ],
              ),

              const VerticalSpace(size: SpaceSize.medium),

              // Todo-Sessions
              ...homeState.sessions.map(
                (SessionWithInstanceModel sessionWithInstance) =>
                    PendingSessionTile(session: sessionWithInstance.session),
              ),
              const VerticalSpace(size: SpaceSize.medium),

              Text("Erledigt", style: context.textTheme.headlineSmall),
              const VerticalSpace(size: SpaceSize.medium),

              // Completed/Skipped sessions
              ...homeState.completedSessionsForToday.map(
                (SessionWithInstanceModel sessionWithInstance) =>
                    CompletedSessionTile(
                      sessionWithInstance: sessionWithInstance,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final int hour = DateTime.now().hour;

    if (hour < 12) return "Morgen ☀️";
    if (hour < 15) return "Tag ⛅️";
    if (hour < 18) return "Nachmittag ⛅️";
    return "Abend 🌙";
  }

  String _getSubHeading() {
    final DateTime now = DateTime.now();
    return DateFormat('EEEE, d. MMMM', 'de_DE').format(now);
  }

  Widget _buildHeading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("Guten ", style: context.textTheme.headlineMedium),
            Text(
              _getGreeting(),
              style: context.textTheme.headlineMedium!.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
        const VerticalSpace(size: SpaceSize.xsmall),
        Text(_getSubHeading()),
      ],
    );
  }
}
