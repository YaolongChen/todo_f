# Shared Layer AGENTS.md

## Scope
Applies to all code under `lib/shared/`. This layer contains reusable assets, entities, and UI components shared across two or more features.

## Internal Structure
```text
lib/shared/
├── constants/
│   ├── route_names.dart   # Centralized route names, paths, and navigation parameter keys
│   └── app_assets.dart    # Asset path constants
├── entities/              # Cross-feature models, entities, and enums (e.g., User, Money, Pagination)
├── i18n/                  # slang sources (`<locale>.i18n.json`) + generated `strings.g.dart`
├── widgets/               # Shared custom widgets, dialogs, buttons, and design system components
└── utils/                 # Business-aware formatters and extensions (e.g., DateFormatters, CurrencyUtils)
```

## Layer Rules & Constraints
1. **Dependency Direction**:
    - CAN import from: `lib/core/`.
    - STRICTLY FORBIDDEN to import from: `lib/features/`.
2. **Route Constants (`shared/constants/route_names.dart`)**:
    - Keep this file strictly declarative with string constants and path builder helpers:
      ```dart
      abstract final class RouteNames {
        static const String home = '/';
        static const String login = '/login';
        static const String orderDetail = '/orders/:id';
        static String orderDetailPath(String id) => '/orders/$id';
      }
      ```
    - **Do NOT import page widgets** or build `GoRoute` instances inside `shared/`.
3. **Shared UI Components (`shared/widgets/`)**:
    - Must be stateless or rely purely on local state (`StatefulWidget` / `ValueNotifier`).
    - **Do NOT bind to feature-specific Providers** directly. All data must be passed in via constructor parameters, and actions must be emitted via callbacks (`VoidCallback`, `ValueChanged<T>`).
4. **Entities (`shared/entities/`)**:
    - Use immutable models
    - Only place models here if they are truly shared across multiple features (e.g., `Response<T>`, `PagedResponse<T>`). Feature-exclusive models must stay inside that feature's own `data/` or `domain/`.