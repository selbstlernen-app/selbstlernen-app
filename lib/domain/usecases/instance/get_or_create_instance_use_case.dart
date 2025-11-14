import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/usecases/instance/create_instance_use_case.dart';

class GetOrCreateInstanceUseCase {
  const GetOrCreateInstanceUseCase(
    this.instanceRepo,
    this.createInstanceUseCase,
  );

  final SessionInstanceRepository instanceRepo;
  final CreateInstanceUseCase createInstanceUseCase;

  Future<SessionInstanceModel> call({
    required int sessionId,
    required DateTime date,
  }) async {
    // Check if instance exists for this session + date
    final SessionInstanceModel? existingInstance = await instanceRepo
        .getInstanceForDate(sessionId, date);

    if (existingInstance != null) {
      // Resume existing instance
      return existingInstance;
    }

    // Create new instance
    SessionInstanceModel newInstance = SessionInstanceModel(
      scheduledAt: DateTime.now(),
      sessionId: sessionId.toString(),
      status: SessionStatus.inProgress,
    );
    int id = await createInstanceUseCase.call(newInstance);
    newInstance = newInstance.copyWith(id: id.toString());

    return newInstance;
  }
}
