import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/general_statistics/widgets/learn_calendar.dart';
import 'package:srl_app/presentation/view_models/statistics/statistics_view_model.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statisticsViewModelProvider);

    if (state.isLoading &&
        state.stats == null &&
        state.enrichedInstances == null) {
      return const LoadingIndicator();
    }

    if (state.error != null && state.stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Fehler: ${state.error}'),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Gesamt-Statistik',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineLarge,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LearnCalendar(enrichedInstances: state.enrichedInstances!),
          ],
        ),
      ),
    );
  }
}
