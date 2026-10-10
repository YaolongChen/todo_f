import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/shared/widgets/app_loading_view.dart';

void main() {
  group('AppLoadingView', () {
    testWidgets('centers a progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingView())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });
  });
}
