---
description: "Use when editing Flutter Dart files, Riverpod state, Aegis protocol client code, auth and session recovery, profile or chat services, localization-backed UI, or Dart test and tool code in TwoSpace."
applyTo: "lib/**/*.dart, test/**/*.dart, tool/**/*.dart"
---

# Flutter And Aegis Client Instructions

## Scope

- Applies to Flutter client code in `lib/`, tests in `test/`, and developer utilities in `tool/`.
- This repository is a client. Do not assume backend or protocol changes exist unless the task explicitly says so.

## Core Rules

- Keep feature logic under `lib/features/...` and shared infrastructure under `lib/core/...`.
- Prefer extending existing services, DTOs, providers, and widgets over adding parallel code paths.
- Keep package imports absolute.
- Match the existing naming and file layout before introducing new types.

GOOD:

- Add a method to `AegisAuthService` if the auth flow already belongs there.
- Update an existing provider when it is already the owner of that state.

BAD:

- Create a second service around the same protocol path because the current one is inconvenient.
- Duplicate profile state in UI and service layers without a clear ownership rule.

## UI Rules

- Reuse the existing theme, spacing, and shared widgets before creating new visual patterns.
- Do not show editable controls for fields the server cannot persist.
- Prefer explicit failure or limitation states over fake success.
- When adding user-facing strings, use localization-aware flow when practical.

GOOD:

- Render an unavailable-state message for unsupported settings.
- Add ARB strings when a new UI message is part of the product.

BAD:

- Keep a save button active for a field that has no protocol support.
- Hardcode scattered user-facing strings that should live in l10n.

## Riverpod And State

- Follow current Riverpod patterns used by the repo.
- Avoid duplicate caches when the service layer already owns the data.
- Prefer narrow notifier updates over broad rebuild churn.
- Do not move network or protocol decisions into leaf widgets unless that pattern already exists and is clearly intended.

## Aegis Rules

- Session recovery must be serialized.
- Avoid overlapping reconnect, disconnect, restore-session, and login flows.
- `Not authenticated` can be transient after reconnect; prefer controlled recovery before treating it as a permanent logout.
- `ProfileGet` and `ProfileUpdate` must be checked for explicit success before trusting payload fields.
- `ChatList` and local room seeds are hints, not final profile truth.
- Keep DTO, protocol client, and service behavior aligned end-to-end.

GOOD:

- Retry through a controlled auth recovery path when reconnect timing can explain a failure.
- Use authoritative profile requests for final profile fields.

BAD:

- Clear stored auth immediately after one authenticated call fails.
- Treat fallback room seed data as canonical profile data.
- Fake client persistence for unsupported protocol features.

## Generated Files

- Do not hand-edit `*.g.dart`, `*.freezed.dart`, or `lib/core/config/env.g.dart`.
- Do not patch platform-generated plugin or registrant outputs by hand unless the task is explicitly about generation or build tooling.
- If annotations, l10n inputs, or `.env` inputs change, regenerate from the source inputs.

## Validation

- Prefer `flutter analyze <changed files>` first.
- Run `flutter gen-l10n` when localization inputs change.
- Run `dart run build_runner build -d` when `freezed`, `json_serializable`, `riverpod`, or `envied` inputs change.
- Run focused tests when behavior changed in a tested area.

## Avoid

- Do not fake protocol support in the client.
- Do not rewrite unrelated files for formatting-only churn.
- Do not add temporary local persistence that conflicts with server-authoritative state unless the task explicitly requires an offline fallback.