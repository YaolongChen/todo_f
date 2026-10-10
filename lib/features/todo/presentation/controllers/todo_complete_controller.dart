import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/features/todo/application/usecases/complete_todo_use_case.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/shared/entities/result.dart';

part 'todo_complete_controller.g.dart';

/// Drives the completion of a single list entry, one controller per todo id.
///
/// The state is a plain `AsyncValue`: `loading` while the write is in flight,
/// `data` once the todo is completed and `error` when the domain refused it.
/// `AsyncValue` asserts that a new `loading` never carries the previous error,
/// so a stale failure cannot be reported twice.
///
/// Being a family keeps that in-flight flag per row: a tap on one entry never
/// blocks another, and the entry that was tapped reports its own failure.
@riverpod
class TodoCompleteController extends _$TodoCompleteController {
  @override
  AsyncValue<void> build(String todoId) => const AsyncData(null);

  /// Completes the todo identified by [todoId] through the use case.
  ///
  /// A tap that arrives while the previous one is still in flight is ignored:
  /// the row is already on its way to the completed state, so a second call
  /// would only produce a spurious "already completed" failure.
  Future<void> complete() async {
    if (state.isLoading) return;

    // Entering `loading` drops any failure from the previous attempt, so the
    // list only ever reports the outcome of the latest tap.
    state = const AsyncLoading();

    final result = await ref.read(completeTodoUseCaseProvider)(todoId);

    if (!ref.mounted) return;

    // The list itself watches the cache, so on success the completed row
    // reaches it without this controller touching the list state.
    state = switch (result) {
      Ok() => const AsyncData(null),
      Error(:final error) => AsyncError(_asFailure(error), StackTrace.current),
    };
  }

  /// Keeps the domain failure when the use case reported one, and falls back to
  /// a save failure for anything else (`lib/features/AGENTS.md`).
  static TodoFailure _asFailure(Object error) => error is TodoFailure
      ? error
      : const TodoSaveFailure(message: '完成待办失败，请稍后重试');
}
