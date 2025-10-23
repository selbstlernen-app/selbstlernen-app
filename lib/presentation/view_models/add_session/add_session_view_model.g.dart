// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_session_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddSessionViewModel)
const addSessionViewModelProvider = AddSessionViewModelProvider._();

final class AddSessionViewModelProvider
    extends $NotifierProvider<AddSessionViewModel, AddSessionState> {
  const AddSessionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addSessionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addSessionViewModelHash();

  @$internal
  @override
  AddSessionViewModel create() => AddSessionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddSessionState>(value),
    );
  }
}

String _$addSessionViewModelHash() =>
    r'840cfcbf213319e44239ed850c05e9424a750a88';

abstract class _$AddSessionViewModel extends $Notifier<AddSessionState> {
  AddSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AddSessionState, AddSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddSessionState, AddSessionState>,
              AddSessionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
