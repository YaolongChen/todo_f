import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/features/todo/application/usecases/watch_todos_use_case.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';

part 'todo_list_controller.g.dart';

/// The cache stream recovers on its own: a failed read is followed by the next
/// local change, and the error view already offers an explicit retry. Riverpod's
/// default policy would instead re-subscribe in a loop on top of that.
Duration? _noAutoRetry(int retryCount, Object error) => null;

/// Owns the state of the todo list screen.
@Riverpod(retry: _noAutoRetry)
class TodoListController extends _$TodoListController {
  @override
  Stream<List<Todo>> build() {
    final watchTodos = ref.watch(watchTodosUseCaseProvider);
    return watchTodos();
  }

  /// Re-subscribes to the cache, which re-reads it from scratch.
  ///
  /// The outcome is published through [state]; awaiting [future] here only keeps
  /// `RefreshIndicator` spinning until the reload settles.
  Future<void> refresh() async {
    ref.invalidateSelf(asReload: true);
    await future;
  }
}
