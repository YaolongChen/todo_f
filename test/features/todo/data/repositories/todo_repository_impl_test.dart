import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/errors/exceptions.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

import '../../helpers/todo_fakes.dart';

void main() {
  group('TodoRepositoryImpl', () {
    final fixedNow = DateTime(2024, 5, 6, 8, 9);

    late FakeTodoLocalDataSource dataSource;
    late TodoRepositoryImpl repository;

    setUp(() {
      dataSource = FakeTodoLocalDataSource();
      repository = TodoRepositoryImpl(localDataSource: dataSource);
    });

    test('insertTodo stores the row of the entity it is handed', () async {
      final todo = Todo.create(
        id: TodoId('todo-1'),
        content: TodoContent('买牛奶'),
        createdAt: fixedNow,
        isCompleted: false,
      );

      final result = await repository.insertTodo(todo);

      expect(result, isA<Ok<void>>());
      expect(dataSource.inserted, hasLength(1));
      final inserted = dataSource.inserted.single;
      expect(inserted.id.value, 'todo-1');
      expect(inserted.content.value, '买牛奶');
      expect(inserted.createdAt.value, fixedNow);
      expect(inserted.isCompleted.value, isFalse);
    });

    test('insertTodo maps storage exceptions to a save failure', () async {
      dataSource.failure = CacheException(message: '保存待办到本地失败');

      final result = await repository.insertTodo(
        Todo.create(
          id: TodoId('todo-1'),
          content: TodoContent('买牛奶'),
          createdAt: fixedNow,
          isCompleted: false,
        ),
      );

      // The repository turns the data source's exception into a failure,
      // carrying the message that layer built.
      expect(failureOf(result), isA<TodoSaveFailure>());
      expect(failureOf(result).message, '保存待办到本地失败');
    });

    test('todoById restores the stored row into an entity', () async {
      dataSource.rows = [
        TodoRow(
          id: 'a',
          content: '买牛奶',
          createdAt: fixedNow,
          isCompleted: false,
        ),
      ];

      final result = await repository.todoById(TodoId('a'));

      final todo = switch (result) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      };
      expect(todo?.id, TodoId('a'));
      expect(todo?.content, TodoContent('买牛奶'));
      expect(todo?.createdAt, fixedNow);
      expect(todo?.isCompleted, isFalse);
    });

    test('todoById answers Ok(null) for an unknown id', () async {
      final result = await repository.todoById(TodoId('missing'));

      expect(switch (result) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      }, isNull);
    });

    test('todoById reports the domain failure for a rejected stored row', () async {
      dataSource.rows = [
        TodoRow(
          id: '',
          content: '买牛奶',
          createdAt: fixedNow,
          isCompleted: false,
        ),
      ];

      final result = await repository.todoById(TodoId(''));

      // A domain failure keeps its own type, so the presentation layer can pick
      // the message for the reason the domain reported.
      expect(failureOf(result), isA<TodoIdEmptyFailure>());
    });

    test('todoById maps storage exceptions to a load failure', () async {
      dataSource.failure = CacheException(message: '读取本地待办失败');

      final result = await repository.todoById(TodoId('a'));

      expect(failureOf(result), isA<TodoLoadFailure>());
      expect(failureOf(result).message, '读取本地待办失败');
    });

    test('saveTodo overwrites the stored row with the entity', () async {
      dataSource.rows = [
        TodoRow(
          id: 'a',
          content: '买牛奶',
          createdAt: fixedNow,
          isCompleted: false,
        ),
      ];
      final completed = Todo.create(
        id: TodoId('a'),
        content: TodoContent('买牛奶'),
        createdAt: fixedNow,
        isCompleted: true,
      );

      final result = await repository.saveTodo(completed);

      expect(switch (result) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      }, isTrue);
      expect(dataSource.updatedIds, ['a']);
      expect(dataSource.rows.single.isCompleted, isTrue);
    });

    test('saveTodo reports Ok(false) when the row is not there', () async {
      final result = await repository.saveTodo(
        Todo.create(
          id: TodoId('missing'),
          content: TodoContent('买牛奶'),
          createdAt: fixedNow,
          isCompleted: true,
        ),
      );

      // "Nothing was written" is a normal answer, not a storage failure.
      expect(switch (result) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      }, isFalse);
      expect(dataSource.inserted, isEmpty);
    });

    test('saveTodo maps storage exceptions to a save failure', () async {
      dataSource.failure = CacheException(message: '更新待办到本地失败');

      final result = await repository.saveTodo(
        Todo.create(
          id: TodoId('a'),
          content: TodoContent('买牛奶'),
          createdAt: fixedNow,
          isCompleted: true,
        ),
      );

      expect(failureOf(result), isA<TodoSaveFailure>());
      expect(failureOf(result).message, '更新待办到本地失败');
    });

    test('todos maps cached rows into entities', () async {
      dataSource.rows = [
        TodoRow(
          id: 'a',
          content: '买牛奶',
          createdAt: fixedNow,
          isCompleted: true,
        ),
        TodoRow(
          id: 'b',
          content: '写代码',
          createdAt: fixedNow,
          isCompleted: false,
        ),
      ];

      final todos = await repository.todos.first;

      expect(todos, hasLength(2));
      expect(todos.map((todo) => todo.content), [
        TodoContent('买牛奶'),
        TodoContent('写代码'),
      ]);
      expect(todos.first.isCompleted, isTrue);
      expect(todos.last.isCompleted, isFalse);
      expect(() => todos.add(todos.first), throwsUnsupportedError);
    });

    test('todos maps storage exceptions to a load failure', () async {
      dataSource.failure = CacheException(message: '读取本地待办失败');

      await expectLater(
        repository.todos,
        emitsError(
          isA<TodoLoadFailure>().having(
            (failure) => failure.message,
            'message',
            contains('读取本地待办失败'),
          ),
        ),
      );
    });

    test('todos maps unexpected errors to a load failure', () async {
      dataSource.failure = StateError('database is closed');

      await expectLater(repository.todos, emitsError(isA<TodoLoadFailure>()));
    });

    test('todos reports the domain failure for an invalid stored id', () async {
      dataSource.rows = [
        TodoRow(
          id: '',
          content: '买牛奶',
          createdAt: fixedNow,
          isCompleted: false,
        ),
      ];

      await expectLater(
        repository.todos,
        emitsError(isA<TodoIdEmptyFailure>()),
      );
    });

    test('todos keeps emitting after a row the domain rejects', () async {
      dataSource.snapshots = [
        [
          TodoRow(
            id: '',
            content: '买牛奶',
            createdAt: fixedNow,
            isCompleted: false,
          ),
        ],
        [
          TodoRow(
            id: 'a',
            content: '买牛奶',
            createdAt: fixedNow,
            isCompleted: false,
          ),
        ],
      ];

      final failures = <Object>[];
      final todos = <List<Todo>>[];
      final sawSnapshot = Completer<void>();

      final subscription = repository.todos.listen((snapshot) {
        todos.add(snapshot);
        if (!sawSnapshot.isCompleted) sawSnapshot.complete();
      }, onError: failures.add);

      await sawSnapshot.future.timeout(const Duration(seconds: 5));
      await subscription.cancel();

      expect(failures, [isA<TodoIdEmptyFailure>()]);
      expect(todos.map((snapshot) => snapshot.single.id), [TodoId('a')]);
    });
  });
}
