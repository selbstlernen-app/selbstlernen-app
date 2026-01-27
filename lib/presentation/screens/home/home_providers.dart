import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';

part 'home_providers.g.dart';

// Watch the stream of sessions for a specific date
@Riverpod(keepAlive: true)
Stream<List<SessionWithInstanceModel>> sessionsForDate(Ref ref, DateTime date) {
  return ref.watch(getSessionsForDateUseCaseProvider).call(date);
}

// Watch the stream of completed sessions for a specific date
@riverpod
Stream<List<SessionWithInstanceModel>> completedSessionsForDate(
  Ref ref,
  DateTime date,
) {
  return ref.watch(getCompletedSessionsForTodayUseCaseProvider).call(date);
}
