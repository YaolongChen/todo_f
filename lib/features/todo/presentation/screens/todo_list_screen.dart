import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/todo/domain/entities/todo.dart';
import 'package:todo/features/todo/presentation/controllers/todo_list_controller.dart';
import 'package:todo/features/todo/presentation/todo_failure_messages.dart';
import 'package:todo/features/todo/presentation/widgets/todo_list_item.dart';
import 'package:todo/shared/constants/route_names.dart';
import 'package:todo/shared/i18n/strings.g.dart';
import 'package:todo/shared/widgets/app_error_view.dart';
import 'package:todo/shared/widgets/app_loading_view.dart';

/// Lists every cached todo and links to the creation screen.
class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListControllerProvider);

    // A failed load changes state outside `build`, so the notification is
    // emitted here, where side effects are allowed (`lib/features/AGENTS.md`).
    // The error view below stays as the persistent state of the screen.
    ref.listen(todoListControllerProvider, (previous, next) {
      if (next case AsyncError(:final error) when error != previous?.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(todoErrorMessage(context.t, error))),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(context.t.todoList.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.todoCreate),
        icon: const Icon(Icons.add),
        label: Text(context.t.todoList.create),
      ),
      body: todos.when(
        data: (items) => _TodoListBody(
          items: items,
          onRefresh: () =>
              ref.read(todoListControllerProvider.notifier).refresh(),
        ),
        loading: () => const AppLoadingView(),
        error: (error, _) => AppErrorView(
          message: todoErrorMessage(context.t, error),
          onRetry: () =>
              ref.read(todoListControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _TodoListBody extends StatelessWidget {
  const _TodoListBody({required this.items, required this.onRefresh});

  final List<Todo> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(hasScrollBody: false, child: _TodoEmptyView()),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) => TodoListItem(todo: items[index]),
      ),
    );
  }
}

class _TodoEmptyView extends StatelessWidget {
  const _TodoEmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(t.todoList.emptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              t.todoList.emptyHint(action: t.todoList.create),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
