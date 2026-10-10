# App Layer AGENTS.md

## Scope
Applies to all code under `lib/app/` (root application entry, app-level routing, root dependency injection, top-level observers).

## Responsibilities
- **Root Router (`lib/app/routes/app_router.dart`)**:
    - This is the **ONLY** place where screen widgets from `features/` are mapped to paths from `shared/constants/route_names.dart`.
    - Configure root redirects, authentication route guards, and error/404 screens here.
- **Root App Entry (`lib/app/main.dart`)**:
    - Configures `MaterialApp.router` with the router instance, theme configurations, and localization delegates.
- **Top-Level Injection (`lib/app/di/`)**:
    - Registers global dependencies, clients, and repositories for use across features.

## Conventions
- Keep page builder callbacks thin: Pass path/query parameters from `GoRouterState` into page constructors without executing feature business logic directly here.