import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/domain/models/session_model.dart';
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
      appBar: AppBar(title: const Text('Sessions')),
      body: ListView.builder(
        itemCount: homeState.sessions.length,
        itemBuilder: (BuildContext context, int index) {
          final SessionModel session = homeState.sessions[index];
          return ListTile(
            title: Text(session.title),
            subtitle: Text(session.focusTimeMin.toString()),
          );
        },
      ),
    );
  }
}
