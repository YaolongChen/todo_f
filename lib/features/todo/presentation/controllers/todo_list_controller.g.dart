// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the state of the todo list screen.

@ProviderFor(TodoListController)
final todoListControllerProvider = TodoListControllerProvider._();

/// Owns the state of the todo list screen.
final class TodoListControllerProvider
    extends $StreamNotifierProvider<TodoListController, List<Todo>> {
  /// Owns the state of the todo list screen.
  TodoListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noAutoRetry,
        name: r'todoListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoListControllerHash();

  @$internal
  @override
  TodoListController create() => TodoListController();
}

String _$todoListControllerHash() =>
    r'ef0e2e763c6cccce48de8d7a4992744f913be887';

/// Owns the state of the todo list screen.

abstract class _$TodoListController extends $StreamNotifier<List<Todo>> {
  Stream<List<Todo>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Todo>>, List<Todo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Todo>>, List<Todo>>,
              AsyncValue<List<Todo>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
