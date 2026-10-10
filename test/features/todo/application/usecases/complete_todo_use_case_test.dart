import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/application/usecases/complete_todo_use_case.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

import '../../helpers/todo_fakes.dart';

void main() {
  group('CompleteTodoUseCase', () {
    final createdAt = DateTime(2024, 5, 6, 8, 9);

    late FakeTodoRepository repository;
    late CompleteTodoUseCase useCase;

    Todo stored({bool isCompleted = false, String id = 'id-1'}) {
      return Todo.create(
        id: TodoId(id),
        content: TodoContent('买牛奶'),
        createdAt: createdAt,
        isCompleted: isCompleted,
      );
    }

    setUp(() {
      repository = FakeTodoRepository();
      useCase = CompleteTodoUseCase(repository);
    });

    tearDown(() => repository.dispose());

    test('rejects a blank id without touching the repository', () async {
      for (final id in ['', '   ', '\n']) {
        final result = await useCase(id);

        expect(failureOf(result), isA<TodoIdEmptyFailure>());
      }

      expect(repository.loadedIds, isEmpty);
      expect(repository.savedTodos, isEmpty);
    });

    test('completes the loaded todo and saves it conditionally', () async {
      repository.todosResult = Result.ok([stored()]);

      final result = await useCase('id-1');

      final completed = switch (result) {
        Ok(:final value) => value,
        Error() => fail('expected an Ok result'),
      };
      expect(completed.isCompleted, isTrue);
      expect(completed.content, TodoContent('买牛奶'));
      expect(completed.createdAt, createdAt);

      expect(repository.loadedIds, [TodoId('id-1')]);
      expect(repository.savedTodos.single, completed);
    });

    test('reports a todo the cache does not hold', () async {
      repository.todosResult = Result.ok(const []);

      final result = await useCase('missing');

      expect(failureOf(result), isA<TodoNotFoundFailure>());
      expect(repository.savedTodos, isEmpty);
    });

    test('refuses to complete an already completed todo', () async {
      repository.todosResult = Result.ok([stored(isCompleted: true)]);

      final result = await useCase('id-1');

      expect(failureOf(result), isA<TodoAlreadyCompletedFailure>());
      expect(repository.savedTodos, isEmpty, reason: 'nothing may be written');
    });

    test('reports a write that found no row as a missing todo', () async {
      // The row disappeared between the read and the write, so nothing landed.
      final racing = _RacingRepository(stored());

      final result = await CompleteTodoUseCase(racing)('id-1');

      expect(failureOf(result), isA<TodoNotFoundFailure>());
      expect(racing.savedTodos, hasLength(1));
    });

    test('propagates a failed read instead of calling it not found', () async {
      repository.todosResult = Result.error(
        const TodoLoadFailure(message: '读取本地待办失败'),
      );

      final result = await useCase('id-1');

      expect(failureOf(result), isA<TodoLoadFailure>());
      expect(failureOf(result).message, '读取本地待办失败');
    });

    test('propagates a failed write', () async {
      final failing = _RacingRepository(
        stored(),
        saveResult: Result.error(TodoSaveFailure(message: '更新待办失败')),
      );

      final result = await CompleteTodoUseCase(failing)('id-1');

      expect(failureOf(result), isA<TodoSaveFailure>());
    });
  });
}

/// Repository double for the write side of the flow.
///
/// The read still answers with a pending todo, so what the write reports is
/// what decides the outcome — for instance a write that finds no row anymore.
final class _RacingRepository implements TodoRepository {
  _RacingRepository(this._stored, {Result<bool>? saveResult})
    : saveResult = saveResult ?? Result.ok(false);

  final Todo _stored;

  /// What the write reports; by default it lands on nothing.
  final Result<bool> saveResult;

  final List<Todo> savedTodos = [];

  @override
  Stream<List<Todo>> get todos => Stream.value([_stored]);

  @override
  Future<Result<void>> insertTodo(Todo todo) async => Result.ok(null);

  @override
  Future<Result<Todo?>> todoById(TodoId id) async => Result.ok(_stored);

  @override
  Future<Result<bool>> saveTodo(Todo todo) async {
    savedTodos.add(todo);
    return saveResult;
  }
}
