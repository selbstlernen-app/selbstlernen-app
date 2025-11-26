import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

/// Use case handling all CRUD operations BUT Read for instance repository
class ManangeInstanceUseCase {
  const ManangeInstanceUseCase(this.repository);

  final SessionInstanceRepository repository;

  // Create
  Future<int> createInstance(SessionInstanceModel instance) =>
      repository.createInstance(instance: instance);

  // Update
  Future<int> updateInstance(SessionInstanceModel updatedInstance) => repository
      .updateInstance(int.parse(updatedInstance.id!), updatedInstance);

  // Delete
  Future<void> deleteInstanceBySessionId(int sessionId) =>
      repository.deleteInstanceBySessionId(sessionId);
}
