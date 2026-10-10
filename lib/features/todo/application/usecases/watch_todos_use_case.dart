import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/features/todo/data/repositories/todo_repository.dart';
import 'package:todo/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';

part 'watch_todos_use_case.g.dart';

/// Streams every todo from the local cache, re-emitting on every change.
final class WatchTodosUseCase {
  const WatchTodosUseCase(this._repository);

  final TodoRepository _repository;

  Stream<List<Todo>> call() => _repository.todos;
}

@Riverpod(keepAlive: true)
WatchTodosUseCase watchTodosUseCase(Ref ref) {
  return WatchTodosUseCase(ref.watch(todoRepositoryProvider));
}
