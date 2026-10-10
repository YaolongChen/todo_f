import 'dart:async';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/core/errors/exceptions.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/data/mappers/todo_mapper.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';

part 'todo_local_data_source.g.dart';

/// Access to the locally cached todo records.
///
/// The local database has no separate DTOs, so implementations speak in terms
/// of the generated table row and companion; `TodoMapper` converts them to and
/// from the domain entity.
///
/// Every storage error leaves this layer as a [CacheException]
/// (`lib/features/AGENTS.md`), so the repository never sees a raw drift error
/// and the failure vocabulary stays in one place.
abstract interface class TodoLocalDataSource {
  /// Emits every cached row, newest first, and re-emits whenever the cache
  /// changes.
  ///
  /// A failure is reported as a [CacheException] error on the stream rather
  /// than thrown synchronously, and it does not end the stream: the next cache
  /// change is delivered as usual.
  Stream<List<TodoRow>> watchTodos();

  /// Inserts [companion] into the local cache.
  Future<void> insertTodo(TodosCompanion companion);

  /// Reads the cached row identified by [id], or `null` when there is none.
  Future<TodoRow?> findTodoById(String id);

  /// Overwrites the row whose id [todo] carries with that todo's fields.
  ///
  /// Returns whether a row was written: `false` means the cache holds no such
  /// todo, so the write had nothing to land on. This layer knows nothing about
  /// when a write is *allowed* — that is the application layer's call.
  Future<bool> updateTodo(Todo todo);
}

/// [TodoLocalDataSource] backed by the local drift database.
final class DriftTodoLocalDataSource implements TodoLocalDataSource {
  const DriftTodoLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TodoRow>> watchTodos() {
    // Newest first.
    final query = _database.select(_database.todos)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    // Drift keeps its query stream alive after a failure, so the error is
    // forwarded as a CacheException without closing the stream.
    return query.watch().transform(
      StreamTransformer<List<TodoRow>, List<TodoRow>>.fromHandlers(
        handleError: (error, stackTrace, sink) => sink.addError(
          CacheException(message: '读取本地待办失败：$error'),
          stackTrace,
        ),
      ),
    );
  }

  @override
  Future<void> insertTodo(TodosCompanion companion) async {
    try {
      await _database.into(_database.todos).insert(companion);
    } catch (error) {
      throw CacheException(message: '保存待办到本地失败：$error');
    }
  }

  @override
  Future<TodoRow?> findTodoById(String id) async {
    try {
      final query = _database.select(_database.todos)
        ..where((table) => table.id.equals(id));

      return await query.getSingleOrNull();
    } catch (error) {
      throw CacheException(message: '读取本地待办失败：$error');
    }
  }

  @override
  Future<bool> updateTodo(Todo todo) async {
    try {
      final updated =
          await (_database.update(_database.todos)
                ..where((table) => table.id.equals(todo.id.value)))
              .write(TodoMapper.toCompanion(todo));

      return updated > 0;
    } catch (error) {
      throw CacheException(message: '更新待办到本地失败：$error');
    }
  }
}

@Riverpod(keepAlive: true)
TodoLocalDataSource todoLocalDataSource(Ref ref) {
  return DriftTodoLocalDataSource(ref.watch(appDatabaseProvider));
}
