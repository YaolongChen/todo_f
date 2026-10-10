import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/application/usecases/watch_todos_use_case.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

import '../../helpers/todo_fakes.dart';

void main() {
  group('WatchTodosUseCase', () {
    late FakeTodoRepository repository;
    late WatchTodosUseCase useCase;

    setUp(() {
      repository = FakeTodoRepository();
      useCase = WatchTodosUseCase(repository);
    });

    test('streams the cached todos', () async {
      final todo = Todo.create(
        id: TodoId('a'),
        content: TodoContent('买牛奶'),
        createdAt: DateTime(2024, 5, 6, 8, 9),
        isCompleted: false,
      );
      repository.todosResult = Result.ok([todo]);

      expect(await useCase().first, [todo]);
    });

    test('propagates the repository failure', () async {
      repository.todosResult = Result.error(
        const TodoLoadFailure(message: '读取本地待办失败'),
      );

      await expectLater(useCase(), emitsError(isA<TodoLoadFailure>()));
    });
  });
}
