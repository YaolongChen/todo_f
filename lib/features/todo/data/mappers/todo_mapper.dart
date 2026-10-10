import 'package:drift/drift.dart';
import 'package:todo/core/store/database/app_database.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';

/// Translates between the local todo table and the domain entity.
///
/// The drift row doubles as the DTO for the local database (see
/// `lib/features/AGENTS.md`), so this class is the only place that knows about
/// both representations.
abstract final class TodoMapper {
  /// Rebuilds a domain entity from a persisted row.
  ///
  /// Stored rows are not trusted: [Todo.create] validates the id and the
  /// content, so a row the domain rejects throws the matching [TodoFailure] and
  /// the repository can report it as a stream error instead of handing out an
  /// entity that breaks the domain rules.
  static Todo toEntity(TodoRow row) {
    return Todo.create(
      id: TodoId(row.id),
      content: TodoContent(row.content),
      createdAt: row.createdAt,
      isCompleted: row.isCompleted,
    );
  }

  /// Turns [todo] into a row ready to be written.
  static TodosCompanion toCompanion(Todo todo) {
    return TodosCompanion(
      id: Value(todo.id.value),
      content: Value(todo.content.value),
      createdAt: Value(todo.createdAt),
      isCompleted: Value(todo.isCompleted),
    );
  }
}
