# Features Layer AGENTS.md

## Scope

Applies to all subdirectories under `lib/features/<feature_name>/`.

## Feature Architecture Standard

Every new feature must follow this strict 4-layer structure:

```text
<feature_name>/
├── data/
│   ├── datasources/              # Remote & local API calls
│   ├── dtos/                     # Freezed/DTO models with fromJson/toJson
│   ├── mappers/                  # Mapper between DTOs and domain entities
│   └── repositories/             # Abstract repository interfaces and concrete repository implementations
├── domain/
│   ├── failures/                 # Business failures
│   ├── value_objects/            # Business field entities
│   └── entities/                 # Pure Dart business entities (no framework imports)
├── application/
│   └── usecases/                 # Single-responsibility use cases
└── presentation/
    ├── screens/                  # Route-level screen
    ├── controllers/              # Controllers, States
    └── widgets/                  # Sub-widgets private to this feature    
```

## Consumption of Core & Shared

- **Using Shared UI**: Prefer using design system widgets from `lib/shared/widgets/` (e.g.,
  `AppButton`, `AppTextInput`) to maintain visual consistency.
- **Using Shared Entities**: Use shared models from `lib/shared/entities/` directly in use cases and
  repository contracts.
- **Cross-Feature Communication**:
    - Never directly import classes from another feature (`import '../../features/other/...'` is
      strictly banned).
    - If two features need the same model or helper, **extract it to `lib/shared/`**.
    - Navigate between features exclusively via the centralized route manager (`go_router`).

## Implementation Guidelines

### 1. Data Layer Rules

- The table entities for local database don't require separate DTO definitions.
- **DataSource** component must handle all exceptions as custom exceptions from
  `lib/core/errors/exceptions.dart`.
- **Repository** component must handle `Exception` types as `Failure` types.
- **Repository** component must return `Result<T>` from
  `lib/shared/entities/result.dart`.

### 2. Domain Layer Rules

- Pure Dart only: No imports from `package:flutter/...`, `dio`, or storage packages.
- Domain failures using `sealed class` to enforce compile-time exhaustiveness checking in UI and
  presentation logic
- Entity is responsible for implementing business behaviors that do not rely on external services.
- Entity use a private default constructor.
- Entity must implement a factory constructor named `create` to instantiate the entity.
- Entity validate inside their constructors and throw the matching `Failure`.
- Value Objects expose a `validate` function that returns a matching `Failure` when the value is invalid.

### 3. Application Layer Rules

- **UseCase** component must return `Result<T>` from
  `lib/shared/entities/result.dart`.

### 4. Presentation Layer Rules

- Keep `build()` pure: Business logic and direct API triggers are strictly banned.
- Side effects (navigation, Snackbars, Dialogs) must be wrapped inside `ref.listen`.
- Use `const` widgets wherever tree rebuilds can be avoided.
- Display message for all **Failures** via side effects.

### 5. Data Flow

- `UI` -> `Controller` -> `UseCase` -> `Repository Interface` -> `Repository Impl` -> `DataSource`.
- Never skip the Repository interface when accessing data.