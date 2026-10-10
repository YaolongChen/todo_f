import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/features/todo/application/usecases/create_todo_use_case.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/shared/entities/result.dart';

part 'todo_create_controller.g.dart';

/// State of the todo creation form.
final class TodoCreateState {
  const TodoCreateState({
    this.isSubmitting = false,
    this.failure,
    this.isSubmitted = false,
  });

  /// `true` while the form is being persisted.
  final bool isSubmitting;

  /// Last failure reported by the create use case, if any.
  final TodoFailure? failure;

  /// `true` once a todo has been created and the screen should close.
  final bool isSubmitted;

  TodoCreateState copyWith({
    bool? isSubmitting,
    TodoFailure? failure,
    bool clearFailure = false,
    bool? isSubmitted,
  }) {
    return TodoCreateState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoCreateState &&
        other.isSubmitting == isSubmitting &&
        other.failure == failure &&
        other.isSubmitted == isSubmitted;
  }

  @override
  int get hashCode => Object.hash(isSubmitting, failure, isSubmitted);
}

/// Drives the todo creation form.
@riverpod
class TodoCreateController extends _$TodoCreateController {
  @override
  TodoCreateState build() => const TodoCreateState();

  /// Validates [content] through the use case and persists it when accepted.
  Future<void> submit(String content) async {
    if (state.isSubmitting) return;

    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      isSubmitted: false,
    );

    final result = await ref.read(createTodoUseCaseProvider)(content);

    if (!ref.mounted) return;

    switch (result) {
      case Ok():
        // The list screen watches the cache, so the insert above already
        // reached it; invalidating the controller here would only re-subscribe.
        state = state.copyWith(isSubmitting: false, isSubmitted: true);
      case Error(:final error):
        state = state.copyWith(
          isSubmitting: false,
          failure: error is TodoFailure
              ? error
              : const TodoSaveFailure(message: '创建待办失败，请稍后重试'),
        );
    }
  }
}
