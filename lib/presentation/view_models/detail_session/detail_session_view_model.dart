import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';

part 'detail_session_view_model.g.dart';

@riverpod
class DetailSessionViewModel extends _$DetailSessionViewModel {
  late final FullSessionUseCase _fullSessionUseCase;
  late final int _sessionId;

  @override
  Stream<DetailSessionState> build(int sessionId) {
    _sessionId = sessionId;
    _fullSessionUseCase = ref.watch(fullSessionUseCaseProvider);

    return _fullSessionUseCase
        .watchFullSession(sessionId)
        .map(
          (FullSessionModel session) =>
              DetailSessionState(fullSession: session),
        );
  }

  Future<void> deleteSession() async {
    await _fullSessionUseCase.deleteFullModel(_sessionId);
  }
}
