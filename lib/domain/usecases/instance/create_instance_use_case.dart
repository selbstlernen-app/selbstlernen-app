import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

/// Use case for when creating a session (when completing a session; or when skipped)
class CreateInstanceUseCase {
  const CreateInstanceUseCase(this.repository, this.sessionRepo);

  final SessionInstanceRepository repository;
  final SessionRepository sessionRepo;

  Future<int> call(SessionInstanceModel instance) async {
    int id = await repository.createInstance(instance: instance);

    return id;
  }
}
