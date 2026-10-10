import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/errors/failures.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

/// Returns the failure carried by [result], failing the test when it is an [Ok].
Failure failureOf(Result<Object?> result) => switch (result) {
  Ok() => fail('expected an Error result but got Ok'),
  Error(:final error) => error,
};

/// Configurable [TodoRepository] test double.
final class FakeTodoRepository implements TodoRepository {
  FakeTodoRepository({Result<List<Todo>>? todosResult, this.insertTodoResult})
    : todosResult = todosResult ?? Result.ok(const []);

  /// Result the [todos] stream mirrors. Mutate it to change the next response.
  Result<List<Todo>> todosResult;

  /// Result returned by [insertTodo]; defaults to a successful insert.
  Result<void>? insertTodoResult;

  /// Todos handed to [insertTodo], in call order.
  final List<Todo> insertedTodos = [];

  /// Ids handed to [todoById], in call order.
  final List<TodoId> loadedIds = [];

  /// Todos handed to [saveTodo], in call order.
  final List<Todo> savedTodos = [];

  /// Number of times [todos] has been listened to, which counts subscriptions
  /// the way the drift query stream does.
  int todosListenCount = 0;

  final StreamController<List<Todo>> _todosController =
      StreamController<List<Todo>>.broadcast();

  /// Serves [todosResult] and re-emits whenever [insertTodo] or [saveTodo]
  /// changes it, so a screen that mutates the cache sees the new state without
  /// re-subscribing, exactly like the drift watch stream.
  @override
  Stream<List<Todo>> get todos {
    _todosController.onListen = () {
      todosListenCount++;
      _emitTodos();
    };
    return _todosController.stream;
  }

  void _emitTodos() {
    if (_todosController.isClosed) return;

    switch (todosResult) {
      case Ok(:final value):
        // A fresh view, so mutating the result in a test stays visible to it.
        _todosController.add(List.unmodifiable(value));
      case Error(:final error):
        // Like drift, an error is reported without ending the stream: the next
        // cache change is still delivered.
        _todosController.addError(error);
    }
  }

  /// Releases the controller a test created through [todos].
  Future<void> dispose() => _todosController.close();

  @override
  Future<Result<void>> insertTodo(Todo todo) async {
    insertedTodos.add(todo);

    final configured = insertTodoResult;
    if (configured != null) return configured;

    // Mirrors the cache: the new row shows up in later snapshots.
    switch (todosResult) {
      case Ok(:final value):
        todosResult = Result.ok([...value, todo]);
      case Error():
        break;
    }
    _emitTodos();

    return Result.ok(null);
  }

  @override
  Future<Result<Todo?>> todoById(TodoId id) async {
    loadedIds.add(id);

    if (todosResult case Error(:final error)) {
      return Result.error(error);
    }

    return Result.ok(switch (todosResult) {
      Ok(:final value) => value.where((todo) => todo.id == id).firstOrNull,
      Error() => null,
    });
  }

  @override
  Future<Result<bool>> saveTodo(Todo todo) async {
    savedTodos.add(todo);

    final current = switch (todosResult) {
      Ok(:final value) => value,
      Error() => const <Todo>[],
    };
    final index = current.indexWhere((stored) => stored.id == todo.id);
    // Mirrors the real write: only an existing row is overwritten.
    if (index == -1) return Result.ok(false);

    current[index] = todo;
    _emitTodos();

    return Result.ok(true);
  }
}

/// Configurable [TodoLocalDataSource] test double.
final class FakeTodoLocalDataSource implements TodoLocalDataSource {
  FakeTodoLocalDataSource({this.rows = const [], this.failure});

  /// Rows emitted by [watchTodos].
  List<TodoRow> rows;

  /// When set, every read reports it instead of succeeding.
  Object? failure;

  /// Companions inserted through [insertTodo].
  final List<TodosCompanion> inserted = [];

  /// Ids handed to [updateTodo], in call order.
  final List<String> updatedIds = [];

  /// When set, [watchTodos] emits these snapshots in order instead of a single
  /// [rows] snapshot, which lets a test drive several emissions.
  List<List<TodoRow>>? snapshots;

  @override
  Stream<List<TodoRow>> watchTodos() {
    final emissions = snapshots;
    if (emissions != null) return Stream.fromIterable(emissions);

    final error = failure;
    if (error != null) return Stream.error(error);
    return Stream.value(rows);
  }

  @override
  Future<void> insertTodo(TodosCompanion companion) async {
    final error = failure;
    if (error != null) throw error;
    inserted.add(companion);
  }

  @override
  Future<TodoRow?> findTodoById(String id) async {
    final error = failure;
    if (error != null) throw error;
    return rows.where((row) => row.id == id).firstOrNull;
  }

  @override
  Future<bool> updateTodo(Todo todo) async {
    final error = failure;
    if (error != null) throw error;

    updatedIds.add(todo.id.value);

    // Mirrors the drift write: only an existing row is overwritten, so an
    // unknown id reports that nothing landed.
    final index = rows.indexWhere((row) => row.id == todo.id.value);
    if (index == -1) return false;

    rows = [...rows]
      ..[index] = TodoRow(
        id: todo.id.value,
        content: todo.content.value,
        createdAt: todo.createdAt,
        isCompleted: todo.isCompleted,
      );
    return true;
  }
}
