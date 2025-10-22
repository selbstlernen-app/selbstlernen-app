// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  const AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'18ce5c8c4d8ddbfe5a7d819d8fb7d5aca76bf416';

@ProviderFor(sessionDao)
const sessionDaoProvider = SessionDaoProvider._();

final class SessionDaoProvider
    extends $FunctionalProvider<SessionDao, SessionDao, SessionDao>
    with $Provider<SessionDao> {
  const SessionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionDaoHash();

  @$internal
  @override
  $ProviderElement<SessionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionDao create(Ref ref) {
    return sessionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionDao>(value),
    );
  }
}

String _$sessionDaoHash() => r'0162a261ce35beeed327a70f4e4d68216ec65ee5';

@ProviderFor(sessionRepository)
const sessionRepositoryProvider = SessionRepositoryProvider._();

final class SessionRepositoryProvider
    extends
        $FunctionalProvider<
          SessionRepository,
          SessionRepository,
          SessionRepository
        >
    with $Provider<SessionRepository> {
  const SessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<SessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionRepository create(Ref ref) {
    return sessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRepository>(value),
    );
  }
}

String _$sessionRepositoryHash() => r'c0994ac20cd79edcb9dababf9c9835938addb421';

@ProviderFor(createSessionUseCase)
const createSessionUseCaseProvider = CreateSessionUseCaseProvider._();

final class CreateSessionUseCaseProvider
    extends
        $FunctionalProvider<
          CreateSessionUseCase,
          CreateSessionUseCase,
          CreateSessionUseCase
        >
    with $Provider<CreateSessionUseCase> {
  const CreateSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateSessionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateSessionUseCase create(Ref ref) {
    return createSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateSessionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateSessionUseCase>(value),
    );
  }
}

String _$createSessionUseCaseHash() =>
    r'7ad9141c90f6d362f709bdd47b8319dcf1027a30';
