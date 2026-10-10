import 'package:todo/features/todo/domain/failures/todo_failures.dart';

/// Content of a todo, modelled as a value object.
///
/// The constructor never rejects input and never throws: it only normalises
/// surrounding whitespace away, which also means the length limit applies to
/// the trimmed value. Validation is explicit through [validate], which reports
/// the matching failure and is run by the todo entity while it builds and by
/// the create use case before it reaches a repository (see
/// `lib/features/AGENTS.md`).
final class TodoContent {
  /// Normalises [value] by trimming surrounding whitespace.
  factory TodoContent(String value) => TodoContent._(value.trim());

  const TodoContent._(this.value);

  /// Maximum number of characters accepted for a todo's content.
  static const int maxLength = 200;

  /// Normalised content value.
  final String value;

  /// Returns why [value] cannot be used as todo content, or `null` when it can.
  ///
  /// [TodoContentEmptyFailure] for empty content and
  /// [TodoContentTooLongFailure] for content beyond [maxLength].
  TodoFailure? validate() {
    if (value.isEmpty) {
      return const TodoContentEmptyFailure();
    }

    if (value.length > maxLength) {
      return const TodoContentTooLongFailure(maxLength: maxLength);
    }

    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoContent && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
