import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/usecases/instance/manange_instance_use_case.dart';

/// Looks up if any instance was created for a given date
/// Returns an instance either created for that date or already existing one
class GetOrCreateInstanceUseCase {
  const GetOrCreateInstanceUseCase(
    this.instanceRepo,
    this.manangeInstanceUseCase,
  );

  final SessionInstanceRepository instanceRepo;
  final ManangeInstanceUseCase manangeInstanceUseCase;

  Future<SessionInstanceModel> call({
    required int sessionId,

    /// The date on which the instance is scheduled for
    required DateTime date,
  }) async {
    // Check if instance exists
    final existingInstance = await instanceRepo
        .getLatestInstanceBySessionIdAndDate(
          sessionId,
          date,
        );

    if (existingInstance != null) {
      return existingInstance;
    }

    // Check the scheduled date to be for the same date but capture the time
    final now = DateTime.now();
    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
      now.second,
    );

    // Create new instance
    var newInstance = SessionInstanceModel(
      scheduledAt: scheduledDate,
      sessionId: sessionId.toString(),
      status: SessionStatus.inProgress,
    );

    final id = await manangeInstanceUseCase.createInstance(newInstance);

    return newInstance = newInstance.copyWith(id: id.toString());
  }
}
