import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/instance_history.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/spent_time_card.dart';

class SessionStatisticsScreen extends ConsumerWidget {
  const SessionStatisticsScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Statistiken')),
      body: FutureBuilder<SessionStatistics>(
        future: ref.read(getSessionStatisticsUseCaseProvider).call(sessionId),
        builder: (BuildContext context, AsyncSnapshot<SessionStatistics> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final SessionStatistics stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Completion Rate Card
                SpentTimeCard(stats: stats),

                const SizedBox(height: 16),

                // TODO: add heatmap style view of all sessions done (if repeating ofc)
                InstanceHistory(sessionId: sessionId),

                // TODO: add average mood description

                // TODO: rework streaks; and how calculated; currently only in row; but not applicable to how days are selected
                CustomButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.home),
                  label: "Zurück zum Startbildschirm",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
