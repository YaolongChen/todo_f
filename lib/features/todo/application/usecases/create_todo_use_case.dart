import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/domain/value_objects/todo_id.dart';
import 'package:todo/shared/entities/result.dart';
import 'package:todo/shared/utils/uuid_generator.dart';

part 'create_todo_use_case.g.dart';

/// Turns raw user input into a valid todo and stores it.
///
/// The business flow is sequenced here:
///
/// 1. the rule itself belongs to the [TodoContent] value object, so
///    `validate()` runs first and rejected input never reaches the repository;
/// 2. the entity is built here, which is what makes the domain rules apply to
///    the created todo — including the identifier [UuidGenerator] mints and the
///    moment it stamps;
/// 3. storage is handed a ready entity, and a rejected identifier or content
///    comes back as the matching failure rather than a stored row.
final class CreateTodoUseCase {
  const CreateTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Returns the [TodoContentEmptyFailure] or [TodoContentTooLongFailure]
  /// reported by [TodoContent.validate] when [content] is rejected; the
  /// repository is not touched in that case.
  Future<Result<Todo>> call(String content) async {
    final todoContent = TodoContent(content);

    // The rule belongs to the value object and the entity validates again while
    // it builds; asking here first is what keeps rejected input out of the data
    // layer entirely.
    final failure = todoContent.validate();
    if (failure != null) {
      return Result.error(failure);
    }

    final Todo todo;
    try {
      todo = Todo.create(
        id: TodoId(UuidGenerator.generate()),
        content: todoContent,
        createdAt: DateTime.now(),
      );
    } on TodoFailure catch (failure) {
      // A generated identifier the domain rejects cannot be caught by
      // validating input, so it still has to leave as a failure.
      return Result.error(failure);
    }

    final stored = await _repository.insertTodo(todo);
    if (stored case Error(:final error)) {
      return Result.error(error);
    }

    return Result.ok(todo);
  }
}

@Riverpod(keepAlive: true)
CreateTodoUseCase createTodoUseCase(Ref ref) {
  return CreateTodoUseCase(ref.watch(todoRepositoryProvider));
}
