import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/errors/exceptions.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';

void main() {
  group('DriftTodoLocalDataSource', () {
    late AppDatabase database;
    late DriftTodoLocalDataSource dataSource;

    TodosCompanion companion({
      required String id,
      required String content,
      required DateTime createdAt,
      bool isCompleted = false,
    }) {
      return TodosCompanion(
        id: Value(id),
        content: Value(content),
        createdAt: Value(createdAt),
        isCompleted: Value(isCompleted),
      );
    }

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      dataSource = DriftTodoLocalDataSource(database);
    });

    tearDown(() => database.close());

    test('persists todos and emits them newest first', () async {
      await dataSource.insertTodo(
        companion(
          id: 'a',
          content: '买牛奶',
          createdAt: DateTime(2024, 5, 6, 8, 9),
        ),
      );
      await dataSource.insertTodo(
        companion(
          id: 'b',
          content: '写代码',
          createdAt: DateTime(2024, 5, 7, 10, 11),
          isCompleted: true,
        ),
      );

      final rows = await dataSource.watchTodos().first;

      expect(rows.map((row) => row.id), ['b', 'a']);
      expect(rows.first.content, '写代码');
      expect(rows.first.createdAt, DateTime(2024, 5, 7, 10, 11));
      expect(rows.first.isCompleted, isTrue);
      expect(rows.last.isCompleted, isFalse);
    });

    test('watchTodos re-emits after an insert', () async {
      final emissions = <List<String>>[];
      final firstEmission = Completer<void>();
      final secondEmission = Completer<void>();

      final subscription = dataSource.watchTodos().listen((rows) {
        emissions.add(rows.map((row) => row.id).toList());
        if (emissions.length == 1) firstEmission.complete();
        if (emissions.length == 2) secondEmission.complete();
      });

      await firstEmission.future.timeout(const Duration(seconds: 5));
      expect(emissions.single, isEmpty);

      await dataSource.insertTodo(
        companion(
          id: 'a',
          content: '买牛奶',
          createdAt: DateTime(2024, 5, 6, 8, 9),
        ),
      );

      await secondEmission.future.timeout(const Duration(seconds: 5));
      expect(emissions, [
        isEmpty,
        ['a'],
      ]);

      await subscription.cancel();
    });

    test('watchTodos reports a storage failure as a cache exception', () async {
      await database.customStatement('DROP TABLE todos');

      // The data source no longer wraps storage errors in a feature-specific
      // type; the repository is what turns them into failures.
      await expectLater(
        dataSource.watchTodos(),
        emitsError(isA<CacheException>()),
      );
    });

    test('defines id and content as non-null primary key columns', () async {
      final ddl = await database
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'todos'",
          )
          .getSingle()
          .then((row) => row.read<String>('sql'));

      printOnFailure('todos DDL: $ddl');

      // Identifiers may be quoted by the dialect; normalise before matching.
      final normalized = ddl.replaceAll(RegExp(r'["`\[\]]'), '');
      expect(
        normalized,
        matches(RegExp(r'id\s+TEXT\s+NOT NULL', caseSensitive: false)),
      );
      expect(
        normalized,
        matches(RegExp(r'content\s+TEXT\s+NOT NULL', caseSensitive: false)),
      );
      expect(normalized, contains('PRIMARY KEY'));
    });

    test('rejects a duplicate id as a storage exception', () async {
      final todo = companion(
        id: 'a',
        content: '买牛奶',
        createdAt: DateTime(2024, 5, 6, 8, 9),
      );
      await dataSource.insertTodo(todo);

      await expectLater(
        dataSource.insertTodo(todo),
        throwsA(isA<CacheException>()),
      );
    });

    test('findTodoById returns the stored row and null when absent', () async {
      await dataSource.insertTodo(
        companion(
          id: 'a',
          content: '买牛奶',
          createdAt: DateTime(2024, 5, 6, 8, 9),
        ),
      );

      final found = await dataSource.findTodoById('a');
      expect(found?.content, '买牛奶');

      // `isNull` alone would be ambiguous here: drift exports a helper with the
      // same name into this test's scope.
      final missing = await dataSource.findTodoById('missing');
      expect(missing, equals(null));
    });

    test('updateTodo writes every field of the todo', () async {
      await dataSource.insertTodo(
        companion(
          id: 'a',
          content: '买牛奶',
          createdAt: DateTime(2024, 5, 6, 8, 9),
        ),
      );

      final completed = Todo.create(
        id: TodoId('a'),
        content: TodoContent('买牛奶（已完成）'),
        createdAt: DateTime(2024, 5, 6, 8, 9),
        isCompleted: true,
      );

      expect(await dataSource.updateTodo(completed), isTrue);

      final row = await dataSource.findTodoById('a');
      expect(row?.isCompleted, isTrue);
      expect(row?.content, '买牛奶（已完成）');
      expect(row?.createdAt, DateTime(2024, 5, 6, 8, 9));
    });

    test('updateTodo overwrites a completed row when asked to', () async {
      await dataSource.insertTodo(
        companion(
          id: 'a',
          content: '买牛奶',
          createdAt: DateTime(2024, 5, 6, 8, 9),
          isCompleted: true,
        ),
      );

      // The layer holds no opinion on whether this write is allowed: it only
      // writes, and the application layer is what refuses the transition.
      final updated = Todo.create(
        id: TodoId('a'),
        content: TodoContent('买牛奶（改过）'),
        createdAt: DateTime(2024, 5, 6, 8, 9),
        isCompleted: true,
      );

      expect(await dataSource.updateTodo(updated), isTrue);

      expect((await dataSource.findTodoById('a'))?.content, '买牛奶（改过）');
    });

    test('updateTodo reports false for an unknown id', () async {
      final orphan = Todo.create(
        id: TodoId('missing'),
        content: TodoContent('买牛奶'),
        createdAt: DateTime(2024, 5, 6, 8, 9),
        isCompleted: true,
      );

      expect(await dataSource.updateTodo(orphan), isFalse);
    });

    test('updateTodo reports a storage failure as a cache exception', () async {
      await database.customStatement('DROP TABLE todos');

      final todo = Todo.create(
        id: TodoId('a'),
        content: TodoContent('买牛奶'),
        createdAt: DateTime(2024, 5, 6, 8, 9),
        isCompleted: true,
      );

      await expectLater(
        dataSource.updateTodo(todo),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
