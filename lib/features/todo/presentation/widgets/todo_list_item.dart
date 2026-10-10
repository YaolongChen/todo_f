import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/domain/failures/todo_failures.dart';
import 'package:todo/features/todo/presentation/controllers/todo_complete_controller.dart';
import 'package:todo/features/todo/presentation/todo_failure_messages.dart';
import 'package:todo/shared/i18n/strings.g.dart';
import 'package:todo/shared/utils/date_formatters.dart';

/// Renders a single todo: its content, creation time and completion status.
///
/// An entry that is still open can be completed by tapping it. The tap goes
/// through [TodoCompleteController], so this widget only renders the in-flight
/// state and reports the outcome; it never touches a repository
/// (`lib/features/AGENTS.md`).
class TodoListItem extends ConsumerWidget {
  const TodoListItem({required this.todo, super.key});

  final Todo todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = context.t;
    final isCompleted = todo.isCompleted;
    final statusColor = isCompleted
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;
    final completion = ref.watch(todoCompleteControllerProvider(todo.id.value));

    // A failure reaches the widget as a change of state, never from `build`
    // itself, so the notification belongs here where side effects are allowed.
    ref.listen(todoCompleteControllerProvider(todo.id.value), (_, next) {
      final error = next.error;
      if (error is TodoFailure) {
        _report(context, todoErrorMessage(t, error));
      }
    });

    return ListTile(
      // Disabled while the write is in flight, which also blocks a second tap.
      enabled: !completion.isLoading,
      onTap: isCompleted ? null : () => _complete(ref),
      leading: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: statusColor,
      ),
      title: Text(
        todo.content.value,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? theme.colorScheme.outline : null,
        ),
      ),
      subtitle: Text(
        DateFormatters.formatDateTime(todo.createdAt),
        style: theme.textTheme.bodySmall,
      ),
      trailing: _Trailing(
        statusColor: statusColor,
        statusLabel: isCompleted
            ? t.todoList.completed
            : t.todoList.notCompleted,
        actionColor: theme.colorScheme.primary,
        actionLabel: t.todoList.completeAction,
        isCompleted: isCompleted,
        isSubmitting: completion.isLoading,
      ),
    );
  }

  void _complete(WidgetRef ref) {
    ref.read(todoCompleteControllerProvider(todo.id.value).notifier).complete();
  }

  void _report(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Status text of an entry, or its completion affordance while it is open.
class _Trailing extends StatelessWidget {
  const _Trailing({
    required this.statusColor,
    required this.statusLabel,
    required this.actionColor,
    required this.actionLabel,
    required this.isCompleted,
    required this.isSubmitting,
  });

  final Color statusColor;
  final String statusLabel;
  final Color actionColor;
  final String actionLabel;
  final bool isCompleted;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSubmitting) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // The action icon is decorative: the status text next to it is what tells
    // the user, and screen readers, in which state the entry is.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          statusLabel,
          style: theme.textTheme.labelMedium?.copyWith(color: statusColor),
        ),
        if (!isCompleted) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: actionColor,
            semanticLabel: actionLabel,
          ),
        ],
      ],
    );
  }
}
