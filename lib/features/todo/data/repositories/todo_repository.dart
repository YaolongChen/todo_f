import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

/// Contract the application layer uses to reach todo data.
abstract interface class TodoRepository {
  /// Emits every cached todo, newest first, and re-emits whenever the local
  /// cache changes, so callers stay in sync without polling.
  ///
  /// Failures are reported as `TodoFailure` errors on the stream, and every
  /// access returns a fresh stream, so hold on to the one you subscribe to.
  Stream<List<Todo>> get todos;

  /// Stores [todo] as a new row in the local cache.
  ///
  /// The entity is built by the application layer, so a todo the domain rejects
  /// never reaches this contract. Whether the row already exists is left to the
  /// storage layer to report.
  Future<Result<void>> insertTodo(Todo todo);

  /// Reads the persisted todo identified by [id].
  ///
  /// `OK(null)` means the cache holds no such todo, which is a distinct answer
  /// from a failed read (`Result.error`): the application layer decides what a
  /// missing todo means, this contract only reports that there is none.
  Future<Result<Todo?>> todoById(TodoId id);

  /// Writes [todo] over the persisted row that shares its identifier.
  ///
  /// Returns whether a row was written; `OK(false)` reports that the cache holds
  /// no such todo, which is a normal answer rather than a failure. Deciding
  /// *when* a write may happen belongs to the application layer, so this
  /// contract carries no precondition.
  ///
  /// The write never inserts: [insertTodo] is the way a todo comes into
  /// existence, so saving an unknown identifier changes nothing.
  Future<Result<bool>> saveTodo(Todo todo);
}
