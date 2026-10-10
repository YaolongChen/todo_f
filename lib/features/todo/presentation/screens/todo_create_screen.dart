import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/todo/domain/value_objects/todo_content.dart';
import 'package:todo/features/todo/presentation/controllers/todo_create_controller.dart';
import 'package:todo/features/todo/presentation/todo_failure_messages.dart';
import 'package:todo/shared/i18n/strings.g.dart';

/// Form screen that creates a todo. Its only field is the content.
class TodoCreateScreen extends ConsumerStatefulWidget {
  const TodoCreateScreen({super.key});

  @override
  ConsumerState<TodoCreateScreen> createState() => _TodoCreateScreenState();
}

class _TodoCreateScreenState extends ConsumerState<TodoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(todoCreateControllerProvider.notifier)
        .submit(_contentController.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoCreateControllerProvider);
    final t = context.t;

    ref.listen(todoCreateControllerProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(todoErrorMessage(context.t, failure))),
        );
        return;
      }

      if (next.isSubmitted && !(previous?.isSubmitted ?? false)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.todoCreate.created)));
        if (context.canPop()) {
          context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(t.todoCreate.title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _contentController,
              autofocus: true,
              enabled: !state.isSubmitting,
              minLines: 1,
              maxLines: 3,
              maxLength: TodoContent.maxLength,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: t.todoCreate.contentLabel,
                hintText: t.todoCreate.contentHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? t.todoCreate.contentRequired
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: state.isSubmitting ? null : _submit,
              icon: state.isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                state.isSubmitting ? t.todoCreate.saving : t.todoCreate.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
