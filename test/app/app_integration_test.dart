import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/app/main.dart';
import 'package:todo/core/store/database/app_database.dart';

void main() {
  testWidgets('creates a todo through the real stack and lists it', (
    tester,
  ) async {
    // No fakes: the real drift data source, repository and use cases run
    // against an in-memory database swapped in for the storage provider.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final database = AppDatabase(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有待办事项'), findsOneWidget);

    await tester.tap(find.text('新建'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '买牛奶');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // Back on the list, read back from the database.
    expect(find.text('待办事项'), findsOneWidget);
    expect(find.text('买牛奶'), findsOneWidget);
    expect(find.text('未完成'), findsOneWidget);

    // Let the confirmation SnackBar timer finish so no timer stays pending.
    await tester.pump(const Duration(seconds: 5));

    // The list listens to a drift query stream, and drift's stream store defers
    // closing a query to a zero-duration timer (see StreamQueryStore
    // .markAsClosed). Dispose the tree here, then elapse a little fake time so
    // that timer runs instead of outliving the test.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
