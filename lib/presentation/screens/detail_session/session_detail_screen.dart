import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_view_model.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DetailSessionState> state = ref.watch(
      detailSessionViewModelProvider(sessionId),
    );

    return state.when(
      loading: () => const LoadingIndicator(),
      error: (Object error, StackTrace stack) =>
          Center(child: Text('Error: $error')),
      data: (DetailSessionState detailState) => MainLayout(
        appBarTitle: "Session Details",
        content: Column(
          children: <Widget>[
            Text("session info"),
            Text(detailState.fullSession.session.toString()),

            Text("goals"),
            Text(detailState.fullSession.goals.toString()),
          ],
        ),
        navigateBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
