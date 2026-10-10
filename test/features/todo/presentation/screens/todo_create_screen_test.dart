import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/presentation/screens/todo_create_screen.dart';
import 'package:todo/shared/constants/route_names.dart';
import 'package:todo/shared/entities/result.dart';
import 'package:todo/shared/i18n/strings.g.dart';

import '../../helpers/todo_fakes.dart';

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: RouteNames.todoCreate,
      routes: [
        GoRoute(
          path: RouteNames.todoList,
          builder: (context, state) =>
              const Scaffold(body: Text('todo-list-page')),
          routes: [
            GoRoute(
              name: RouteNames.todoCreate,
              path: 'todos/create',
              builder: (context, state) => const TodoCreateScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pumpCreateScreen(
    WidgetTester tester,
    TodoRepository repository,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWith((ref) => repository)],
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: buildRouter()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('exposes the content field as its only form field', (
    tester,
  ) async {
    await pumpCreateScreen(tester, FakeTodoRepository());

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('内容'), findsOneWidget);
  });

  testWidgets('blocks submission when the content is empty', (tester) async {
    final repository = FakeTodoRepository();
    await pumpCreateScreen(tester, repository);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('内容不能为空'), findsOneWidget);
    expect(repository.insertedTodos, isEmpty);
  });

  testWidgets('creates a trimmed todo and returns to the list', (tester) async {
    final repository = FakeTodoRepository();
    await pumpCreateScreen(tester, repository);

    await tester.enterText(find.byType(TextFormField), '  买牛奶  ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(repository.insertedTodos.single.content, TodoContent('买牛奶'));
    expect(find.text('todo-list-page'), findsOneWidget);

    // Let the confirmation SnackBar timer finish so no timer stays pending.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('reports a failure and keeps the form open', (tester) async {
    final repository = FakeTodoRepository(
      insertTodoResult: Result.error(const TodoSaveFailure(message: '保存到本地失败')),
    );
    await pumpCreateScreen(tester, repository);

    await tester.enterText(find.byType(TextFormField), '买牛奶');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('待办保存失败，请稍后重试'), findsOneWidget);
    expect(find.byType(TodoCreateScreen), findsOneWidget);

    // Let the failure SnackBar timer finish so no timer stays pending.
    await tester.pump(const Duration(seconds: 5));
  });
}
