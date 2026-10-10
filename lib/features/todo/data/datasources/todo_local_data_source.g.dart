// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoLocalDataSource)
final todoLocalDataSourceProvider = TodoLocalDataSourceProvider._();

final class TodoLocalDataSourceProvider
    extends
        $FunctionalProvider<
          TodoLocalDataSource,
          TodoLocalDataSource,
          TodoLocalDataSource
        >
    with $Provider<TodoLocalDataSource> {
  TodoLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<TodoLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodoLocalDataSource create(Ref ref) {
    return todoLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoLocalDataSource>(value),
    );
  }
}

String _$todoLocalDataSourceHash() =>
    r'e46cba800416f480674e1f4da661337b61f563c4';
