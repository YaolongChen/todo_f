# Root AGENTS.md

## Multi-Level Instructions Routing (Lazy Loading Protocol)

> **CRITICAL AGENT INSTRUCTION**:
> Do **NOT** preload or read all sub-`AGENTS.md` files at session start.
> Only inspect the specific subordinate `AGENTS.md` when your active task requires modifying files
> within that designated scope.

| Scope / Target Directory | Instruction File         | When to Load                                           |
|:-------------------------|:-------------------------|:-------------------------------------------------------|
| `lib/app/**`             | `lib/app/AGENTS.md`      | Editing root router, global DI, or app bootstrap       |
| `lib/features/**`        | `lib/features/AGENTS.md` | Creating/modifying business features, pages, or state  |
| `lib/shared/**`          | `lib/shared/AGENTS.md`   | Adding shared UI widgets, route constants, common DTOs |
| `lib/core/**`            | `lib/core/AGENTS.md`     | Modifying network client, storage engine, base errors  |

### Execution Workflow for the Agent:

1. **Identify Scope**: Determine which layer the requested task belongs to based on the target file
   path.
2. **On-Demand Read**: If and only if you touch a directory listed above, execute `read_file` on its
   corresponding `AGENTS.md` before generating code.

---

## Scope & Priority

- This file governs the entire repository.
- Subdirectory `AGENTS.md` files inherit these rules and append localized guidelines. In case of
  conflict, the narrower scope wins unless explicitly forbidden below.

## Global Tech Stack

- Flutter SDK: 3.47+ | Dart SDK: 3.13+
- State Management: `flutter_riverpod`
- Network: `dio` + `retrofit`
- Routing: `go_router`
- Data Model: `freezed`, `json_serializable`
- Local Store: `drift`, `shared_preferences`
- Localization / Internationalization (i18n): `slang`

## High-Level Architecture & Dependency Rules

Strictly adhere to the unidirectional dependency flow:

- **`app/`**: Root application assembly layer (main entry point, root `GoRouter` table, global DI
  setup, app lifecycle). May depend on all layers (`features/`, `shared/`, `core/`).
- **`core/`**: Infrastructure level (Network client, Storage engine, Global errors). Depends on
  NOTHING internal.
- **`shared/`**: Cross-feature entities, reusable UI design-system widgets, and shared utilities.
  May depend on `core/`, but **NEVER on `features/`**.
- **`features/`**: Feature-specific business logic and views. May depend on `core/` and `shared/`.
  Direct cross-feature imports are prohibited.

## Routing Architecture Rules

- **Route Constants**: Define route names, paths, and query parameter keys in
  `lib/shared/constants/route_names.dart`. Features must trigger navigation via these shared
  constants (e.g., `context.pushNamed(RouteNames.orderDetail)`).
- **Route Table Assembly**: Assemble the complete `GoRouter` instance in
  `lib/app/routes/app_router.dart`.
- **Core Isolation**: Never put page route configurations or `GoRoute` instances in `lib/core/` to
  prevent infrastructure from depending on UI layers.

## Non-Negotiable Rules

1. **Never write raw SQL or HTTP calls inside UI components.**
2. **Never install new dependencies** in `pubspec.yaml` without explicit confirmation.
3. **No deprecated Flutter/Dart APIs** (e.g., use `PopScope` instead of `WillPopScope`).

## Tooling & Verification Workflow

After making Dart/Flutter changes, run:

- Format & Lint: `dart format .` and `flutter analyze`
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Unit/Widget Tests: `flutter test`