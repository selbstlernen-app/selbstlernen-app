import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/presentation/screens/home/widgets/session_tile.dart';
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
    final HomeState homeState = ref.watch(homeViewModelProvider);

    if (homeState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (homeState.error != null) {
      return Scaffold(body: Center(child: Text('Error: ${homeState.error}')));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        title: Text('Home', style: context.textTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.builder(
          itemCount: homeState.sessions.length,
          itemBuilder: (BuildContext context, int index) {
            final SessionModel session = homeState.sessions[index];
            return SessionTile(session: session);
          },
        ),
      ),
    );
  }
}
