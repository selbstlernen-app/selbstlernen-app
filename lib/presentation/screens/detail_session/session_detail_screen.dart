import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_view_model.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});
  final int sessionId;

  void _deleteSession(BuildContext context, WidgetRef ref) {
    ref
        .read(detailSessionViewModelProvider(sessionId).notifier)
        .deleteSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const MainNavigation(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DetailSessionState> state = ref.watch(
      detailSessionViewModelProvider(sessionId),
    );

    return state.when(
      loading: () => const LoadingIndicator(),
      error: (Object error, StackTrace stack) =>
          Center(child: Text('Error: $error')),
      data: (DetailSessionState detailState) {
        final SessionModel session = detailState.fullSession.session;
        return MainLayout(
          navigateBack: () {
            Navigator.pop(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => const MainNavigation(),
              ),
            );
          },
          appBarTitle: session.title,
          actions: <Widget>[
            IconButton(
              onPressed: () => print("Edit"),
              icon: const Icon(Icons.mode_edit_outline_rounded),
            ),
            IconButton(
              onPressed: () => _deleteSession(context, ref),
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          ],
          content: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Deine Ziele für diese Einheit",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      ...detailState.fullSession.goals.map((GoalModel goal) {
                        return Text(goal.title);
                      }),

                      const VerticalSpace(size: SpaceSize.large),

                      Text(
                        "Deine Strategien",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      Text(session.learningStrategies.toString()),

                      const VerticalSpace(size: SpaceSize.large),

                      Text(
                        "Geplante Zeit",
                        style: context.textTheme.headlineMedium,
                      ),
                      const VerticalSpace(size: SpaceSize.small),
                      Text(session.focusTimeMin.toString()),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: context.mediaQuery.size.width,
                child: CustomButton(
                  onPressed: () => print("go"),
                  label: "Starten",
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
