import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';

void main() {
  group('TodoContent', () {
    test('reports the empty-content failure for an empty value', () {
      expect(TodoContent('').validate(), isA<TodoContentEmptyFailure>());
    });

    test('reports the empty-content failure for a whitespace-only value', () {
      expect(TodoContent('   ').validate(), isA<TodoContentEmptyFailure>());
      expect(TodoContent('\n\t').validate(), isA<TodoContentEmptyFailure>());
    });

    test('accepts content exactly at the configured limit', () {
      final atLimit = 'a' * TodoContent.maxLength;

      expect(TodoContent(atLimit).value, atLimit);
      expect(TodoContent(atLimit).validate(), isNull);
    });

    test('reports the too-long failure carrying the exceeded limit', () {
      expect(
        TodoContent('a' * (TodoContent.maxLength + 1)).validate(),
        isA<TodoContentTooLongFailure>().having(
          (failure) => failure.maxLength,
          'maxLength',
          TodoContent.maxLength,
        ),
      );
    });

    test('constructs rejected values without throwing', () {
      expect(() => TodoContent(''), returnsNormally);
      expect(
        () => TodoContent('a' * (TodoContent.maxLength + 1)),
        returnsNormally,
      );
      expect(TodoContent('').value, '');
    });

    test('normalises surrounding whitespace', () {
      expect(TodoContent('  买牛奶  ').value, '买牛奶');
      expect(TodoContent('  买牛奶  ').validate(), isNull);
    });

    test('measures the length limit against the normalised value', () {
      final paddedToLimit = '  ${'a' * TodoContent.maxLength}  ';

      expect(paddedToLimit.length, greaterThan(TodoContent.maxLength));
      expect(TodoContent(paddedToLimit).validate(), isNull);
    });

    test('has value equality', () {
      expect(TodoContent('买牛奶'), TodoContent('买牛奶'));
      expect(TodoContent('买牛奶').hashCode, TodoContent('买牛奶').hashCode);
      expect(TodoContent('买牛奶'), isNot(TodoContent('写代码')));
    });

    test('renders as its raw value', () {
      expect(TodoContent('买牛奶').toString(), '买牛奶');
    });
  });
}
