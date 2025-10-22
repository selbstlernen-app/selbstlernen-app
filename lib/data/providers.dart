import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/repositories/session_repository_imp.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/usecases/create_session_use_case.dart';

part 'providers.g.dart';

// Database and DAOs
@riverpod
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@riverpod
SessionDao sessionDao(Ref ref) {
  return SessionDao(ref.watch(appDatabaseProvider));
}

// Repository
@riverpod
SessionRepository sessionRepository(Ref ref) {
  return SessionRepositoryImp(ref.watch(sessionDaoProvider));
}

// UseCases
@riverpod
CreateSessionUseCase createSessionUseCase(Ref ref) {
  return CreateSessionUseCase(ref.watch(sessionRepositoryProvider));
}
