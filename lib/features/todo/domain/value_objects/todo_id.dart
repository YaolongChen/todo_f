import 'package:todo/features/todo/domain/failures/todo_failures.dart';

/// Identity of a todo, modelled as a value object.
///
/// The constructor keeps [value] as given and never throws; [validate] is the
/// single gate deciding whether the identifier is usable, and the todo entity
/// runs it while it builds. Keeping the check out of the constructor makes
/// construction cheap for the places that merely transport an identifier
/// (mappers, tests) while an invalid id still surfaces as a domain failure:
/// [TodoFailure] is sealed, so presentation code can switch over it
/// exhaustively, and the repository turns it into `Result.error(...)` instead
/// of letting it escape. Note that `Exception` types are reserved for data
/// sources by `lib/features/AGENTS.md`.
final class TodoId {
  /// Keeps [value] untouched; validation happens in [validate].
  factory TodoId(String value) => TodoId._(value);

  const TodoId._(this.value);

  /// Raw identifier value.
  final String value;

  /// Returns [TodoIdEmptyFailure] when [value] is empty or whitespace-only, or
  /// `null` when the identifier is usable.
  TodoFailure? validate() =>
      value.trim().isEmpty ? const TodoIdEmptyFailure() : null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
