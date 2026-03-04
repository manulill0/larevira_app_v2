---
name: "La Revira App v2 Agent Guide"
description: "Repository-specific instructions for coding agents and contributors working on the Flutter app for La Revirá"
category: "Flutter Mobile App"
author: "Codex"
tags:
  [
    "flutter",
    "dart",
    "riverpod",
    "go-router",
    "drift",
    "dio",
    "mobile",
    "offline-cache",
  ]
lastUpdated: "2026-03-04"
---

# La Revira App v2 Agent Guide

## Purpose

This file defines how an agent should work in this repository.
Use it as the project-specific source of truth before making changes.

The app is a Flutter mobile client for La Revirá with:

- Riverpod for state and dependency wiring
- GoRouter for navigation
- Drift + SQLite for local persistence
- Dio for HTTP access and cache-assisted offline fallback
- A custom theme system with adaptive scaling and the `Cinzel` font family

## Current Project Shape

The codebase already follows a feature-oriented structure.
Prefer extending the existing modules instead of introducing new top-level
folders.

```text
lib/
  main.dart
  app.dart
  core/
    config/
    local/
    models/
    network/
    routing/
    theme/
    time/
    widgets/
  features/
    home/
    hoy/
    jornadas/
    more/
    planning/
    shared/
    sync/
```

### Important entry points

- `lib/main.dart`: boots Flutter and wraps the app with `ProviderScope`
- `lib/app.dart`: creates `MaterialApp.router`, applies theme mode and
  screen-size theme adaptation
- `lib/core/routing/app_router.dart`: central router with startup redirect and
  bottom-navigation shell
- `lib/core/local/app_database.dart`: Drift schema, migrations, and local cache
- `lib/core/network/larevira_api_client.dart`: scoped API client and HTTP cache
- `lib/features/sync/application/sync_controller.dart`: initial/manual sync
  orchestration

## Working Conventions

### Architecture

- Keep shared infrastructure in `lib/core/`
- Keep user-facing flows in `lib/features/<feature>/`
- Prefer adding feature logic inside an existing feature before creating a new
  one
- Keep presentation, application, and persistence concerns separated when the
  feature grows

### Riverpod

- Match the style already used in the repo
- Prefer `Provider`, `NotifierProvider`, and `ConsumerWidget`/`ConsumerStatefulWidget`
  unless there is a clear reason to introduce generated providers
- Read dependencies from `ref.read(...)` in commands and `ref.watch(...)` in
  reactive UI/build flows
- Invalidate dependent providers after mutations when stale UI is possible

### Routing

- Define route paths/names in `lib/core/routing/app_routes.dart`
- Register navigation behavior in `lib/core/routing/app_router.dart`
- Preserve the startup gate behavior driven by `SyncState`
- Prefer passing rich objects through `state.extra` only when it avoids a second
  lookup and does not replace path params needed for deep links

### Database and persistence

- Do not hand-edit generated files such as `lib/core/local/app_database.g.dart`
- When changing Drift tables:
  - update `schemaVersion`
  - add an explicit migration path in `onUpgrade`
  - keep backward compatibility for existing installs
- Prefer transactional writes for multi-table updates
- Keep cache keys deterministic and stable

### Networking

- Reuse `LareviraApiClient` instead of creating ad hoc Dio clients
- Prefer the existing scoped path helpers for city/year-aware endpoints
- Preserve offline fallback behavior when changing network flows
- Treat malformed payloads as state errors instead of silently ignoring them

### UI and theming

- Reuse `AppTheme` and `AppColors`
- Keep the current visual identity: warm palette, `Cinzel` for headings, Material 3
- Prefer small private widgets over long `build` methods
- Use `const` constructors and widgets where possible

## Change Rules

- Make the smallest coherent change that solves the task
- Preserve existing names unless a rename is necessary
- Avoid adding dependencies unless the repo cannot solve the task with the
  current stack
- If a generated-code workflow is introduced or changed, document the command in
  the relevant file or PR notes
- Keep code ASCII unless the file already uses specific non-ASCII content

## Validation

Run the lightest relevant checks after changes:

```bash
flutter analyze
flutter test
```

If you touch generated Drift or Riverpod code, also run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Common Task Playbooks

### Add a new screen

1. Create the page inside the relevant `lib/features/.../presentation/` folder
2. Add any state/controller logic under that feature's `application/` folder
3. Register the route in `app_routes.dart` and `app_router.dart` if navigable
4. Reuse existing theme tokens and navigation patterns

### Add or change synced data

1. Update the API parsing model in `lib/core/models/`
2. Extend `LareviraApiClient` usage only if the endpoint shape requires it
3. Update Drift schema and migrations if local persistence changes
4. Update `sync_controller.dart` and invalidate affected providers
5. Verify fallback behavior with cached data still makes sense

### Change theme behavior

1. Prefer editing `lib/core/theme/app_theme.dart` or `app_colors.dart`
2. Keep light and dark themes aligned
3. Preserve screen-size adaptation unless the task explicitly changes it

## How To Use This File

If you are working with an AI coding agent, reference this file explicitly in
your prompt and describe the task in repository terms.

Good prompt examples:

- "Read `AGENTS.md` and add a new tab under `lib/features/more/`"
- "Follow `AGENTS.md` and update the sync flow to cache a new endpoint"
- "Using the conventions in `AGENTS.md`, refactor `app_router.dart` without
  changing behavior"

This helps the agent avoid generic Flutter patterns that do not match the
project.

## What This File Is Not

- It is not end-user documentation
- It is not a full product spec
- It should not duplicate implementation details that belong inside the code

Keep it updated when the repository structure, architecture, or workflows
change.
