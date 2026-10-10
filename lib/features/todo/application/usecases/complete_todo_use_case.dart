import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

part 'complete_todo_use_case.g.dart';

/// Completes a persisted todo identified by its raw identifier.
///
/// The business flow is sequenced here, because the transition needs both a
/// piece of the domain and a piece of storage:
///
/// 1. the identifier becomes a [TodoId] and is validated, so unusable input
///    never reaches the repository;
/// 2. the current state is loaded, and that state is authoritative — what the
///    screen holds may already be stale;
/// 3. [Todo.complete] runs on that entity: the domain decides whether the
///    transition is allowed and builds the completed state;
/// 4. the result is persisted, and a write that found no row is reported as a
///    todo that is not there;
/// 5. every outcome becomes a `Result`, since `Todo.complete` reports its
///    failure by throwing.
final class CompleteTodoUseCase {
  const CompleteTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Returns the [TodoIdEmptyFailure] reported by [TodoId.validate] when [id]
  /// is rejected, or the matching failure for a todo the cache does not hold, a
  /// todo that is completed already, and a failed read or write.
  Future<Result<Todo>> call(String id) async {
    final todoId = TodoId(id);
    final invalid = todoId.validate();
    if (invalid != null) {
      return Result.error(invalid);
    }

    final loaded = await _repository.todoById(todoId);
    // Unwrapping first keeps the shape of each outcome readable: a failed read
    // is already the right failure, and calling it "not found" would lose why
    // the load failed.
    final Todo? loadedTodo = switch (loaded) {
      Ok(:final value) => value,
      Error() => null,
    };

    if (loaded case Error(:final error)) {
      return Result.error(error);
    }
    if (loadedTodo == null) {
      return Result.error(const TodoNotFoundFailure());
    }

    final Todo completed;
    try {
      completed = loadedTodo.complete();
    } on TodoFailure catch (failure) {
      return Result.error(failure);
    }

    final saved = await _repository.saveTodo(completed);
    if (saved case Error(:final error)) {
      return Result.error(error);
    }
    // `false` means the row disappeared between the read above and this write,
    // which is the same "no such todo" answer the read could have given.
    if (saved case Ok(value: false)) {
      return Result.error(const TodoNotFoundFailure());
    }

    return Result.ok(completed);
  }
}

@Riverpod(keepAlive: true)
CompleteTodoUseCase completeTodoUseCase(Ref ref) {
  return CompleteTodoUseCase(ref.watch(todoRepositoryProvider));
}
