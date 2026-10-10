import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/app/main.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';

import '../features/todo/helpers/todo_fakes.dart';

void main() {
  testWidgets('boots on the todo list and navigates to the creation screen', (
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
      ]),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [todoRepositoryProvider.overrideWith((ref) => repository)],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('待办事项'), findsOneWidget);
    expect(find.text('买牛奶'), findsOneWidget);

    await tester.tap(find.text('新建'));
    await tester.pumpAndSettle();

    expect(find.text('新建待办'), findsOneWidget);
    expect(find.text('内容'), findsOneWidget);
  });
}
