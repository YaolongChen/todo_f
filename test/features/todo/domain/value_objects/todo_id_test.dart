import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';

void main() {
  group('TodoId', () {
    test('reports the empty-id failure for an empty value', () {
      expect(TodoId('').validate(), isA<TodoIdEmptyFailure>());
    });

    test('reports the empty-id failure for a whitespace-only value', () {
      expect(TodoId('   ').validate(), isA<TodoIdEmptyFailure>());
      expect(TodoId('\n\t').validate(), isA<TodoIdEmptyFailure>());
    });

    test('accepts a usable identifier', () {
      expect(TodoId('todo-1').validate(), isNull);
    });

    test('constructs rejected values without throwing', () {
      expect(() => TodoId(''), returnsNormally);
      expect(TodoId('').value, '');
    });

    test('keeps a valid value untouched', () {
      expect(TodoId('todo-1').value, 'todo-1');
    });

    test('has value equality', () {
      expect(TodoId('todo-1'), TodoId('todo-1'));
      expect(TodoId('todo-1').hashCode, TodoId('todo-1').hashCode);
      expect(TodoId('todo-1'), isNot(TodoId('todo-2')));
    });

    test('renders as its raw value', () {
      expect(TodoId('todo-1').toString(), 'todo-1');
    });
  });
}
