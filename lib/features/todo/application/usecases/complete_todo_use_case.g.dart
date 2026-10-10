// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_todo_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(completeTodoUseCase)
final completeTodoUseCaseProvider = CompleteTodoUseCaseProvider._();

final class CompleteTodoUseCaseProvider
    extends
        $FunctionalProvider<
          CompleteTodoUseCase,
          CompleteTodoUseCase,
          CompleteTodoUseCase
        >
    with $Provider<CompleteTodoUseCase> {
  CompleteTodoUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeTodoUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeTodoUseCaseHash();

  @$internal
  @override
  $ProviderElement<CompleteTodoUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompleteTodoUseCase create(Ref ref) {
    return completeTodoUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteTodoUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteTodoUseCase>(value),
    );
  }
}

String _$completeTodoUseCaseHash() =>
    r'eae584a751ade5c7d3ebcf066f3c46eea612d49e';
