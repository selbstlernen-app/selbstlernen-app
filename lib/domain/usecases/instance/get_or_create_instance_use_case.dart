import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/usecases/instance/manange_instance_use_case.dart';

class GetOrCreateInstanceUseCase {
  const GetOrCreateInstanceUseCase(
    this.instanceRepo,
    this.manangeInstanceUseCase,
  );

  final SessionInstanceRepository instanceRepo;
  final ManangeInstanceUseCase manangeInstanceUseCase;

  Future<SessionInstanceModel> call({
    required int sessionId,
    required DateTime date,
  }) async {
    // Check if instance exists for this session + date
    final existingInstance = await instanceRepo.getInstanceForDate(
      sessionId,
      date,
    );

    if (existingInstance != null) {
      // Resume existing instance
      return existingInstance;
    }

    // Create new instance
    var newInstance = SessionInstanceModel(
      scheduledAt: DateTime.now(),
      sessionId: sessionId.toString(),
      status: SessionStatus.inProgress,
    );
    final id = await manangeInstanceUseCase.createInstance(newInstance);

    return newInstance = newInstance.copyWith(id: id.toString());
  }
}
