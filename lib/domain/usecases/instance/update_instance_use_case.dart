import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class UpdateInstanceUseCase {
  const UpdateInstanceUseCase(this.instanceRepo);

  final SessionInstanceRepository instanceRepo;

  Future<void> call(SessionInstanceModel updatedInstance) async {
    if (updatedInstance.id == null) {
      throw ArgumentError('Cannot update instance without an ID');
    }

    await instanceRepo.updateInstance(
      int.parse(updatedInstance.id!),
      updatedInstance,
    );
  }
}
