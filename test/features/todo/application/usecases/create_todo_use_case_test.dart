import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/application/usecases/create_todo_use_case.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/shared/entities/result.dart';

import '../../helpers/todo_fakes.dart';

void main() {
  group('CreateTodoUseCase', () {
    late FakeTodoRepository repository;
    late CreateTodoUseCase useCase;

    setUp(() {
      repository = FakeTodoRepository();
      useCase = CreateTodoUseCase(repository);
    });

    tearDown(() => repository.dispose());

    test('rejects empty content without touching the repository', () async {
      for (final content in ['', '   ', '\n']) {
        final result = await useCase(content);

        expect(failureOf(result), isA<TodoContentEmptyFailure>());
      }

      expect(repository.insertedTodos, isEmpty);
    });

    test('rejects content longer than the accepted limit', () async {
      final tooLong = 'a' * (TodoContent.maxLength + 1);

      final result = await useCase(tooLong);

      expect(
        failureOf(result),
        isA<TodoContentTooLongFailure>().having(
          (failure) => failure.maxLength,
          'maxLength',
          TodoContent.maxLength,
        ),
      );
      expect(repository.insertedTodos, isEmpty);
    });

    test('builds the todo, mints an id and stamps the creation time', () async {
      final before = DateTime.now();

      final result = await useCase('  买牛奶  ');

      final after = DateTime.now();
      final created = switch (result) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      };
      expect(created.content, TodoContent('买牛奶'));
      expect(created.isCompleted, isFalse, reason: 'a new todo is always open');

      // The id comes from UuidGenerator, so the test checks the shape it
      // promises rather than a value the use case can no longer be told.
      expect(
        created.id.value,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
            r'[0-9a-f]{12}$',
          ),
        ),
      );
      // Likewise the clock: the stamp has to be the moment of the call.
      expect(created.createdAt.isBefore(before), isFalse);
      expect(created.createdAt.isAfter(after), isFalse);

      expect(repository.insertedTodos.single, created);
    });

    test('mints a fresh id for every todo', () async {
      final first = await useCase('买牛奶');
      final second = await useCase('写代码');

      final firstTodo = switch (first) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      };
      final secondTodo = switch (second) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      };

      expect(firstTodo.id, isNot(equals(secondTodo.id)));
      expect(repository.insertedTodos, hasLength(2));
    });

    test('propagates the repository failure', () async {
      repository.insertTodoResult = Result.error(
        const TodoSaveFailure(message: '写不进去'),
      );

      final result = await useCase('买牛奶');

      expect(failureOf(result), isA<TodoSaveFailure>());
      expect(failureOf(result).message, '写不进去');
    });
  });
}
