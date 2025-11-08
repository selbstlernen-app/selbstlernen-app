import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class CreateSessionInstanceUseCase {
  const CreateSessionInstanceUseCase(this.instanceRepository);
  final SessionInstanceRepository instanceRepository;

  Future<int> call(SessionInstanceModel instance) async {
    final int id = await instanceRepository.addSessionInstance(instance);

    return id;
  }
}
