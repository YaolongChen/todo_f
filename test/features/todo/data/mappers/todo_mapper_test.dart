import 'package:flutter_test/flutter_test.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/data/mappers/todo_mapper.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';

void main() {
  group('TodoMapper', () {
    final createdAt = DateTime(2024, 5, 6, 8, 9);

    test('toEntity rebuilds every field of the domain entity', () {
      final todo = TodoMapper.toEntity(
        TodoRow(
          id: 'a',
          content: '买牛奶',
          createdAt: createdAt,
          isCompleted: true,
        ),
      );

      expect(
        todo,
        Todo.create(
          id: TodoId('a'),
          content: TodoContent('买牛奶'),
          createdAt: createdAt,
          isCompleted: true,
        ),
      );
      expect(todo.isCompleted, isTrue);
    });

    test('toCompanion carries every field of the domain entity', () {
      final companion = TodoMapper.toCompanion(
        Todo.create(
          id: TodoId('a'),
          content: TodoContent('买牛奶'),
          createdAt: createdAt,
          isCompleted: true,
        ),
      );

      expect(companion.id.value, 'a');
      expect(companion.content.value, '买牛奶');
      expect(companion.createdAt.value, createdAt);
      expect(companion.isCompleted.value, isTrue);
    });

    test('toEntity reports the domain failure for a rejected id', () {
      expect(
        () => TodoMapper.toEntity(
          TodoRow(
            id: '   ',
            content: '买牛奶',
            createdAt: createdAt,
            isCompleted: false,
          ),
        ),
        throwsA(isA<TodoIdEmptyFailure>()),
      );
    });

    test('toEntity reports the domain failure for rejected content', () {
      expect(
        () => TodoMapper.toEntity(
          TodoRow(
            id: 'a',
            content: '   ',
            createdAt: createdAt,
            isCompleted: false,
          ),
        ),
        throwsA(isA<TodoContentEmptyFailure>()),
      );
    });
  });
}
