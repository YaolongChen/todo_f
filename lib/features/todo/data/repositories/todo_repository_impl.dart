import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/core/errors/exceptions.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:todo/features/todo/data/mappers/todo_mapper.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

part 'todo_repository_impl.g.dart';

/// Local cache backed implementation of [TodoRepository].
///
/// Table rows are turned into domain entities through [TodoMapper]. Nothing
/// escapes this class as a thrown object, and it holds no business rules:
/// [todos] reports storage exceptions and rows the domain rejects as stream
/// errors, while the write methods give their failures back as [Result.error].
final class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl({required this._localDataSource});

  final TodoLocalDataSource _localDataSource;

  @override
  Stream<List<Todo>> get todos {
    try {
      return _localDataSource.watchTodos().transform(
        StreamTransformer<List<TodoRow>, List<Todo>>.fromHandlers(
          handleData: (rows, sink) {
            try {
              sink.add(List<Todo>.unmodifiable(rows.map(TodoMapper.toEntity)));
            } catch (error) {
              // A row the domain rejects is reported without tearing the stream
              // down, so later cache changes still reach the listener.
              sink.addError(_loadFailureFrom(error), StackTrace.current);
            }
          },
          handleError: (error, stackTrace, sink) =>
              sink.addError(_loadFailureFrom(error), stackTrace),
        ),
      );
    } catch (error) {
      return Stream.error(_loadFailureFrom(error));
    }
  }

  @override
  Future<Result<void>> insertTodo(Todo todo) async {
    try {
      await _localDataSource.insertTodo(TodoMapper.toCompanion(todo));
      return Result.ok(null);
    } catch (error) {
      return Result.error(_saveFailureFrom(error, '创建待办失败'));
    }
  }

  @override
  Future<Result<Todo?>> todoById(TodoId id) async {
    try {
      final row = await _localDataSource.findTodoById(id.value);
      if (row == null) {
        return Result.ok(null);
      }

      // Stored rows are not trusted: a row the domain rejects surfaces as the
      // matching failure instead of an entity that breaks the rules.
      return Result.ok(TodoMapper.toEntity(row));
    } catch (error) {
      return Result.error(_loadFailureFrom(error));
    }
  }

  @override
  Future<Result<bool>> saveTodo(Todo todo) async {
    try {
      final updated = await _localDataSource.updateTodo(todo);

      return Result.ok(updated);
    } catch (error) {
      return Result.error(_saveFailureFrom(error, '更新待办失败'));
    }
  }

  /// Maps a failure raised while reading the cache to the matching [TodoFailure].
  ///
  /// A domain failure passes through unchanged: `TodoFailure` is sealed and the
  /// presentation layer picks its message by type, so re-wrapping one would
  /// replace the reason the domain reported. Anything else is a storage error,
  /// which the data source raises as an `Exception` (`lib/features/AGENTS.md`).
  static TodoFailure _loadFailureFrom(Object error) => switch (error) {
    TodoFailure() => error,
    CacheException(:final message) => TodoLoadFailure(message: message),
    _ => TodoLoadFailure(message: '加载待办失败：$error'),
  };

  /// Maps a failure raised while writing the cache to the matching [TodoFailure].
  static TodoFailure _saveFailureFrom(Object error, String context) =>
      switch (error) {
        TodoFailure() => error,
        CacheException(:final message) => TodoSaveFailure(message: message),
        _ => TodoSaveFailure(message: '$context：$error'),
      };
}

@Riverpod(keepAlive: true)
TodoRepository todoRepository(Ref ref) {
  return TodoRepositoryImpl(
    localDataSource: ref.watch(todoLocalDataSourceProvider),
  );
}
