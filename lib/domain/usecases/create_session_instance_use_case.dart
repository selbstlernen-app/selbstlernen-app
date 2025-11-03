import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class CreateSessionInstanceUseCase {
  const CreateSessionInstanceUseCase(this.repository);
  final SessionInstanceRepository repository;

  Future<int> call(SessionInstanceModel instance) =>
      repository.addSessionInstance(instance);
}
