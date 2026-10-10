import 'package:flutter/material.dart';
import 'package:todo/shared/i18n/strings.g.dart';

/// Full-area error placeholder with an optional retry action.
///
/// Feature-agnostic by design (see `lib/shared/AGENTS.md`): the caller passes the
/// already localised [message] and the [onRetry] callback, so the widget never
/// touches feature providers or failures. When [onRetry] is `null` only the
/// message is shown, which covers errors the user cannot act on.
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.message, this.onRetry, super.key});

  /// Text describing what went wrong, already translated for display.
  final String message;

  /// Invoked when the user taps the retry action. Hidden while `null`.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final retry = onRetry;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (retry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: retry,
                child: Text(context.t.common.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
