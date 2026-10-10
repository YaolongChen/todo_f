import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/shared/i18n/strings.g.dart';

/// Turns a failure into the text a user reads.
///
/// `lib/features/AGENTS.md` requires failures to be converted based on their
/// type, so this is the single place where the todo feature decides what to
/// show. The switch has no catch-all arm over [TodoFailure] on purpose: adding a
/// failure type without deciding its copy becomes a compile error.
///
/// [translations] is passed in rather than read from the ambient locale, which
/// keeps this helper pure and unit-testable; widgets hand over `context.t`.
///
/// No arm relies on `Failure.message`, which stays diagnostic: load/save
/// failures may embed storage internals (`加载待办失败：StateError...`) and
/// [TodoIdEmptyFailure] reports a programming error the user cannot act on.
String todoErrorMessage(Translations translations, Object error) {
  if (error is! TodoFailure) {
    return translations.todoFailures.unknown;
  }

  return switch (error) {
    TodoContentEmptyFailure() => translations.todoFailures.contentEmpty,
    TodoContentTooLongFailure(:final maxLength) =>
      translations.todoFailures.contentTooLong(maxLength: maxLength),
    TodoIdEmptyFailure() => translations.todoFailures.invalidData,
    TodoAlreadyCompletedFailure() => translations.todoFailures.alreadyCompleted,
    TodoNotFoundFailure() => translations.todoFailures.notFound,
    TodoLoadFailure() => translations.todoFailures.load,
    TodoSaveFailure() => translations.todoFailures.save,
  };
}
