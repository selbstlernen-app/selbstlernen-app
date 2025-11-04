import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class CreateSessionInstanceUseCase {
  const CreateSessionInstanceUseCase(
    this.sessionRepository,
    this.instanceRepository,
  );
  final SessionInstanceRepository instanceRepository;
  final SessionRepository sessionRepository;

  Future<int> createSessionInstance(SessionInstanceModel instance) async {
    final int id = await instanceRepository.addSessionInstance(instance);

    if (instance.status == SessionStatus.completed) {
      await sessionRepository.patchIncrementCompletedInstances(
        int.parse(instance.sessionId),
      );
    }
    return id;
  }
}
