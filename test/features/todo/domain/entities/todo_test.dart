import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';

void main() {
  group('Todo', () {
    final createdAt = DateTime(2024, 5, 6, 8, 9);

    Todo buildTodo({TodoContent? content, bool isCompleted = false}) {
      return Todo.create(
        id: TodoId('id-1'),
        content: content ?? TodoContent('买牛奶'),
        createdAt: createdAt,
        isCompleted: isCompleted,
      );
    }

    test('create defaults to not completed', () {
      final todo = Todo.create(
        id: TodoId('id-1'),
        content: TodoContent('买牛奶'),
        createdAt: createdAt,
      );

      expect(todo.id, TodoId('id-1'));
      expect(todo.content, TodoContent('买牛奶'));
      expect(todo.createdAt, createdAt);
      expect(todo.isCompleted, isFalse);
    });

    test('create keeps the persisted completion state it is given', () {
      final pending = buildTodo();
      final done = buildTodo(isCompleted: true);

      expect(pending.isCompleted, isFalse);
      expect(done.isCompleted, isTrue);
      expect(done.id, pending.id);
      expect(done.content, pending.content);
      expect(done.createdAt, pending.createdAt);
    });

    test('complete builds the completed todo and keeps the other fields', () {
      final todo = buildTodo();

      final completed = todo.complete();

      expect(completed.isCompleted, isTrue);
      expect(completed.id, todo.id);
      expect(completed.content, todo.content);
      expect(completed.createdAt, todo.createdAt);
      expect(todo.isCompleted, isFalse, reason: 'the original stays untouched');
    });

    test('complete throws when the todo is already completed', () {
      expect(
        () => buildTodo(isCompleted: true).complete(),
        throwsA(isA<TodoAlreadyCompletedFailure>()),
      );
    });

    test('has value equality', () {
      expect(buildTodo(), equals(buildTodo()));
      expect(buildTodo().hashCode, equals(buildTodo().hashCode));
      expect(buildTodo(), isNot(equals(buildTodo(isCompleted: true))));
      expect(
        buildTodo(),
        isNot(equals(buildTodo(content: TodoContent('写代码')))),
      );
    });

    test('create throws the failure reported for an empty id', () {
      expect(
        () => Todo.create(
          id: TodoId('   '),
          content: TodoContent('买牛奶'),
          createdAt: createdAt,
        ),
        throwsA(isA<TodoIdEmptyFailure>()),
      );
    });

    test('create throws the failure reported for empty content', () {
      expect(
        () => Todo.create(
          id: TodoId('id-1'),
          content: TodoContent(''),
          createdAt: createdAt,
        ),
        throwsA(isA<TodoContentEmptyFailure>()),
      );
    });

    test('create rejects a persisted row the domain refuses', () {
      expect(
        () => Todo.create(
          id: TodoId('id-1'),
          content: TodoContent('a' * (TodoContent.maxLength + 1)),
          createdAt: createdAt,
          isCompleted: true,
        ),
        throwsA(isA<TodoContentTooLongFailure>()),
      );
    });
  });
}
