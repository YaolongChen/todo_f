import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/presentation/screens/todo_list_screen.dart';
import 'package:todo/shared/entities/result.dart';
import 'package:todo/shared/i18n/strings.g.dart';

import '../../helpers/todo_fakes.dart';

void main() {
  Future<void> pumpListScreen(
    WidgetTester tester,
    TodoRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWith((ref) => repository)],
        child: TranslationProvider(
          child: const MaterialApp(home: TodoListScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders content, creation time and completion status', (
    tester,
  ) async {
    final repository = FakeTodoRepository(
      todosResult: Result.ok([
        Todo.create(
          id: TodoId('a'),
          content: TodoContent('买牛奶'),
          createdAt: DateTime(2024, 5, 6, 8, 9),
          isCompleted: false,
        ),
        Todo.create(
          id: TodoId('b'),
          content: TodoContent('写代码'),
          createdAt: DateTime(2024, 5, 6, 9, 10),
          isCompleted: true,
        ),
      ]),
    );

    await pumpListScreen(tester, repository);

    expect(find.text('买牛奶'), findsOneWidget);
    expect(find.text('2024-05-06 08:09'), findsOneWidget);
    expect(find.text('未完成'), findsOneWidget);

    expect(find.text('写代码'), findsOneWidget);
    expect(find.text('2024-05-06 09:10'), findsOneWidget);
    expect(find.text('已完成'), findsOneWidget);
  });

  testWidgets('shows an empty state when nothing is cached', (tester) async {
    await pumpListScreen(tester, FakeTodoRepository());

    expect(find.text('还没有待办事项'), findsOneWidget);
  });

  testWidgets('completes a pending todo when it is tapped', (tester) async {
    final repository = FakeTodoRepository(
      todosResult: Result.ok([
        Todo.create(
          id: TodoId('a'),
          content: TodoContent('买牛奶'),
          createdAt: DateTime(2024, 5, 6, 8, 9),
          isCompleted: false,
        ),
      ]),
    );
    await pumpListScreen(tester, repository);

    await tester.tap(find.text('买牛奶'));
    await tester.pumpAndSettle();

    expect(repository.loadedIds, [TodoId('a')]);
    expect(repository.savedTodos.single.isCompleted, isTrue);
    expect(find.text('已完成'), findsOneWidget);
    expect(find.text('未完成'), findsNothing);
  });

  testWidgets('shows a snackbar when completing a todo fails', (tester) async {
    // The row still renders as pending; only the write fails, which is the case
    // the snackbar exists for.
    await pumpListScreen(tester, _FailingSaveRepository());

    await tester.tap(find.text('买牛奶'));
    await tester.pump();

    expect(find.text('待办保存失败，请稍后重试'), findsOneWidget);
    expect(find.text('未完成'), findsOneWidget);
  });

  testWidgets('hides the completion action for a finished todo', (
    tester,
  ) async {
    final repository = FakeTodoRepository(
      todosResult: Result.ok([
        Todo.create(
          id: TodoId('a'),
          content: TodoContent('买牛奶'),
          createdAt: DateTime(2024, 5, 6, 8, 9),
          isCompleted: true,
        ),
      ]),
    );
    await pumpListScreen(tester, repository);

    expect(find.text('已完成'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });

  testWidgets('shows the failure message and recovers through retry', (
    tester,
  ) async {
    final repository = FakeTodoRepository(
      todosResult: Result.error(const TodoLoadFailure(message: '读取本地待办失败')),
    );

    await pumpListScreen(tester, repository);

    // The failure reaches the user twice by design: as the persistent state of
    // the screen, and as the side-effect notification the rules ask for.
    expect(find.text('待办加载失败，请稍后重试'), findsNWidgets(2));

    repository.todosResult = Result.ok([
      Todo.create(
        id: TodoId('a'),
        content: TodoContent('买牛奶'),
        createdAt: DateTime(2024, 5, 6, 8, 9),
        isCompleted: false,
      ),
    ]);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('买牛奶'), findsOneWidget);
    // The initial subscription plus the fresh one refresh() creates.
    expect(repository.todosListenCount, 2);

    // Let the notification timer finish so no timer stays pending.
    await tester.pump(const Duration(seconds: 5));
  });
}

/// Repository double whose read succeeds and whose write fails.
///
/// Only the write path is interesting here: the row must keep rendering as
/// pending so the snackbar is the one thing that changes.
final class _FailingSaveRepository implements TodoRepository {
  final Todo _todo = Todo.create(
    id: TodoId('a'),
    content: TodoContent('买牛奶'),
    createdAt: DateTime(2024, 5, 6, 8, 9),
    isCompleted: false,
  );

  @override
  Stream<List<Todo>> get todos => Stream.value([_todo]);

  @override
  Future<Result<void>> insertTodo(Todo todo) async => Result.ok(null);

  @override
  Future<Result<Todo?>> todoById(TodoId id) async => Result.ok(_todo);

  @override
  Future<Result<bool>> saveTodo(Todo todo) async =>
      Result.error(const TodoSaveFailure(message: '写不进去'));
}
