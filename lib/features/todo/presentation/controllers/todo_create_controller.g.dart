// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_create_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the todo creation form.

@ProviderFor(TodoCreateController)
final todoCreateControllerProvider = TodoCreateControllerProvider._();

/// Drives the todo creation form.
final class TodoCreateControllerProvider
    extends $NotifierProvider<TodoCreateController, TodoCreateState> {
  /// Drives the todo creation form.
  TodoCreateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoCreateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoCreateControllerHash();

  @$internal
  @override
  TodoCreateController create() => TodoCreateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoCreateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoCreateState>(value),
    );
  }
}

String _$todoCreateControllerHash() =>
    r'e592fde26cc91d4d527eb0d4c24523cc700bd59a';

/// Drives the todo creation form.

abstract class _$TodoCreateController extends $Notifier<TodoCreateState> {
  TodoCreateState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TodoCreateState, TodoCreateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodoCreateState, TodoCreateState>,
              TodoCreateState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
