import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/shared/i18n/strings.g.dart';
import 'package:todo/shared/widgets/app_error_view.dart';

void main() {
  group('AppErrorView', () {
    Future<void> pumpView(WidgetTester tester, Widget view) {
      return tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(home: Scaffold(body: view)),
        ),
      );
    }

    testWidgets('renders the message next to an error icon', (tester) async {
      await pumpView(tester, const AppErrorView(message: '待办加载失败'));

      expect(find.text('待办加载失败'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('hides the retry action when no callback is given', (
      tester,
    ) async {
      await pumpView(tester, const AppErrorView(message: '待办加载失败'));

      expect(find.text('重试'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('runs the callback when the retry action is tapped', (
      tester,
    ) async {
      var retries = 0;

      await pumpView(
        tester,
        AppErrorView(message: '待办加载失败', onRetry: () => retries++),
      );

      await tester.tap(find.text('重试'));
      await tester.pump();

      expect(retries, 1);
    });
  });
}
