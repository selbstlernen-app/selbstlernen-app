import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

/// Use case handling all CRUD operations BUT Read for instance repository
class ManangeInstanceUseCase {
  const ManangeInstanceUseCase(this.repository, this.sessionRepository);

  final SessionInstanceRepository repository;
  final SessionRepository sessionRepository;

  // Create
  Future<int> createInstance(SessionInstanceModel instance) =>
      repository.createInstance(instance: instance);

  // Update
  Future<int> updateInstance(SessionInstanceModel updatedInstance) async {
    // Update the instance
    final result = await repository.updateInstance(
      int.parse(updatedInstance.id!),
      updatedInstance,
    );

    // Update the instance's session; modify updatedAt date
    await sessionRepository.touchSession(int.parse(updatedInstance.sessionId));

    return result;
  }

  // Delete
  Future<void> deleteInstanceBySessionId(int sessionId) =>
      repository.deleteInstanceBySessionId(sessionId);

  // Delete
  Future<void> deleteInstanceById(int instanceId) =>
      repository.deleteInstanceById(instanceId);
}
