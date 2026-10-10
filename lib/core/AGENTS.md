# Core Layer AGENTS.md

## Scope

Applies to all code under `lib/core/` (network, storage, theme, error handling, extensions).

## Architectural Boundaries

- `core/` must only depend on pure Dart/Flutter SDKs or external low-level utility libraries.
- **Zero Business Knowledge**: Never import from `lib/features/` OR `lib/shared/`.
- **Global Error Handling**:
    - All external failures (Dio, Storage, Device APIs) must be caught and mapped to unified domain
      `Failure` subclasses defined in `lib/core/errors/failures.dart`.
    - Do not let raw `DioException` or platform exceptions leak outside this layer.

## Responsibilities

- **Network Engine**: Unified Dio/HTTP configuration, base interceptors, base client wrappers.
- **Storage Infrastructure**: Key-value engines, database setup/open logic.
- **Unified Error Handling**: Base `Failure` and `Exception` contracts (`lib/core/errors/`). Map all
  external framework/SDK exceptions here.
- **Base Theme**: Low-level theme tokens (palette definitions, raw font definitions), not full-blown
  business widgets.