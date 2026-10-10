import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';

/// Pure business entity describing a single todo item.
///
/// The default constructor is private and [Todo.create] is the single factory
/// that instantiates the entity, whether it is brand new or rebuilt from a
/// persisted state. The entity also implements its own business behaviours —
/// [Todo.complete] is one, and it needs nothing outside the domain.
///
/// Validation belongs to the entity constructors (see `lib/features/AGENTS.md`),
/// so a todo that exists has always been validated. The rules themselves live in
/// the value objects: [TodoId.validate] and [TodoContent.validate] report the
/// matching [TodoFailure], and the constructors turn a report into a throw.
final class Todo {
  const Todo._({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.isCompleted,
  });

  /// Instantiates a todo from its full state.
  ///
  /// A brand new todo is not completed, which is why [isCompleted] defaults to
  /// `false`; rebuilding one that was persisted passes the stored flag
  /// explicitly.
  ///
  /// Throws the failure reported by [TodoId.validate] or
  /// [TodoContent.validate] when [id] or [content] is rejected, so persisted
  /// rows are validated like any other input.
  factory Todo.create({
    required TodoId id,
    required TodoContent content,
    required DateTime createdAt,
    bool isCompleted = false,
  }) {
    return Todo._validated(
      id: id,
      content: content,
      createdAt: createdAt,
      isCompleted: isCompleted,
    );
  }

  /// Marks the todo as completed and returns the resulting entity.
  ///
  /// A business behaviour the entity owns: it needs nothing outside the domain.
  /// Completion is a one-off transition, so an already completed todo throws
  /// [TodoAlreadyCompletedFailure] instead of returning an equal todo, and the
  /// completed entity is built through the same validating constructor.
  Todo complete() {
    if (isCompleted) {
      throw const TodoAlreadyCompletedFailure();
    }

    return Todo._validated(
      id: id,
      content: content,
      createdAt: createdAt,
      isCompleted: true,
    );
  }

  /// Single validating entry point shared by every named constructor.
  ///
  /// The rules live in the value objects, so this only asks their `validate()`
  /// and turns a report into a throw: a path that builds an entity breaking the
  /// domain rules cannot complete.
  factory Todo._validated({
    required TodoId id,
    required TodoContent content,
    required DateTime createdAt,
    required bool isCompleted,
  }) {
    final failure = id.validate() ?? content.validate();
    if (failure != null) {
      throw failure;
    }

    return Todo._(
      id: id,
      content: content,
      createdAt: createdAt,
      isCompleted: isCompleted,
    );
  }

  /// Identity of the todo.
  final TodoId id;

  /// Content of the todo.
  final TodoContent content;

  /// Moment the todo was created.
  final DateTime createdAt;

  /// Whether the todo has been completed.
  final bool isCompleted;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => Object.hash(id, content, createdAt, isCompleted);

  @override
  String toString() =>
      'Todo(id: $id, content: $content, createdAt: $createdAt, '
      'isCompleted: $isCompleted)';
}
