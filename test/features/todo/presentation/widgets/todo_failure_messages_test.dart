import 'package:flutter_test/flutter_test.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/presentation/todo_failure_messages.dart';
import 'package:todo/shared/i18n/strings.g.dart';

void main() {
  group('todoErrorMessage', () {
    test('renders empty content validation', () {
      expect(todoErrorMessage(t, const TodoContentEmptyFailure()), '待办内容不能为空');
    });

    test('renders the limit carried by the too-long failure', () {
      expect(
        todoErrorMessage(t, const TodoContentTooLongFailure(maxLength: 200)),
        '待办内容不能超过 200 个字符',
      );
    });

    test('hides the internal id failure behind a generic message', () {
      expect(todoErrorMessage(t, const TodoIdEmptyFailure()), '待办数据异常，请稍后重试');
    });

    test('renders the repeated-completion failure', () {
      expect(
        todoErrorMessage(t, const TodoAlreadyCompletedFailure()),
        '待办已完成，请勿重复操作',
      );
    });

    test('never leaks storage internals from a load failure', () {
      expect(
        todoErrorMessage(
          t,
          const TodoLoadFailure(message: '加载待办失败：StateError: closed'),
        ),
        '待办加载失败，请稍后重试',
      );
    });

    test('never leaks storage internals from a save failure', () {
      expect(
        todoErrorMessage(
          t,
          const TodoSaveFailure(message: '创建待办失败：SqliteException'),
        ),
        '待办保存失败，请稍后重试',
      );
    });

    test('falls back for errors that are not domain failures', () {
      expect(todoErrorMessage(t, StateError('boom')), '待办操作失败，请稍后重试');
    });
  });
}
