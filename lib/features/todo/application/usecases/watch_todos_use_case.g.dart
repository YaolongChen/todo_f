// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_todos_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watchTodosUseCase)
final watchTodosUseCaseProvider = WatchTodosUseCaseProvider._();

final class WatchTodosUseCaseProvider
    extends
        $FunctionalProvider<
          WatchTodosUseCase,
          WatchTodosUseCase,
          WatchTodosUseCase
        >
    with $Provider<WatchTodosUseCase> {
  WatchTodosUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchTodosUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchTodosUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchTodosUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchTodosUseCase create(Ref ref) {
    return watchTodosUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchTodosUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchTodosUseCase>(value),
    );
  }
}

String _$watchTodosUseCaseHash() => r'7cef376fe96f02681965ce8a210ea017a44d30fa';
