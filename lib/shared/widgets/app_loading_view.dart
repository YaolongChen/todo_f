import 'package:flutter/material.dart';

/// Full-area loading placeholder.
///
/// Feature-agnostic by design (see `lib/shared/AGENTS.md`): it owns no state and
/// subscribes to nothing, so screens can drop it into an `AsyncValue` loading
/// branch as is. Inline spinners for buttons or list rows are a different shape
/// and should stay local to their widget.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
