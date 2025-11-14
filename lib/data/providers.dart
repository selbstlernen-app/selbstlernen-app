import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/goal_dao.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/database/daos/session_instance_dao.dart';
import 'package:srl_app/data/database/daos/task_dao.dart';
import 'package:srl_app/data/repositories/goal_repository_imp.dart';
import 'package:srl_app/data/repositories/session_instance_repository_imp.dart';
import 'package:srl_app/data/repositories/session_repository_imp.dart';
import 'package:srl_app/data/repositories/task_repository_imp.dart';
import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/task_repository.dart';

part 'providers.g.dart';

// --- Database and DAOs ---
@Riverpod(keepAlive: true) // Should be kept alive to ensure singleton
AppDatabase appDatabase(Ref ref) {
  return AppDatabase();
}

@riverpod
SessionDao sessionDao(Ref ref) {
  return SessionDao(ref.watch(appDatabaseProvider));
}

@riverpod
TaskDao taskDao(Ref ref) {
  return TaskDao(ref.watch(appDatabaseProvider));
}

@riverpod
GoalDao goalDao(Ref ref) {
  return GoalDao(ref.watch(appDatabaseProvider));
}

@riverpod
SessionInstanceDao sessionInstanceDao(Ref ref) {
  return SessionInstanceDao(ref.watch(appDatabaseProvider));
}

// --- Repositories ---
@riverpod
SessionRepository sessionRepository(Ref ref) {
  return SessionRepositoryImp(ref.watch(sessionDaoProvider));
}

@riverpod
SessionInstanceRepository sessionInstanceRepository(Ref ref) {
  return SessionInstanceRepositoryImp(ref.watch(sessionInstanceDaoProvider));
}

@riverpod
TaskRepository taskRepository(Ref ref) {
  return TaskRepositoryImp(ref.watch(taskDaoProvider));
}

@riverpod
GoalRepository goalRepository(Ref ref) {
  return GoalRepositoryImp(ref.watch(goalDaoProvider));
}
