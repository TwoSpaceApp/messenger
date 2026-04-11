# Agent Guide for TwoSpace Messenger

This guide defines repository-wide instructions for coding agents working with the TwoSpace Flutter client.

## Mission

- Treat this repository as a Flutter client first, not as a place to compensate for missing backend behavior.
- Prefer root-cause fixes over UI-only masking.
- Keep changes local, deliberate, and easy to review.
- Do not invent protocol capabilities that the Aegis server does not expose.

## Repository Shape

- `lib/core/` contains shared infrastructure such as config, routing, protocol client, services, and reusable widgets.
- `lib/features/` is feature-first and should contain most app-specific behavior.
- `lib/core/network/aegis/` and `lib/features/auth|chat/data/services/` are the most sensitive protocol paths.
- `lib/l10n/` contains localization inputs and generated localization outputs.
- `tool/` contains probes and developer utilities, not production app code.
- `test/` contains automated tests.
- `.github/workflows/` contains CI and should only be changed for build, validation, or release-flow tasks.

## Working Style

- Read the affected path before editing it.
- Do not behave as if you understood a code path before reading the relevant files.
- Prefer changing an existing service, notifier, DTO, or widget over adding a parallel abstraction.
- Keep package imports absolute: `package:two_space_app/...`.
- Preserve existing architecture unless the task explicitly requires a structural change.
- Do not overwrite unrelated user edits.

GOOD:

- Read the service, provider, and screen involved in a bug before proposing a fix.
- Say clearly when a behavior still depends on code or protocol you have not inspected yet.
- Ask in simple Russian before changing a distinctive UI solution that may be intentional.
- Extend `AegisChatService` if chat/profile behavior already lives there.
- Add a small helper in an existing notifier if the state already belongs to that notifier.
- Reuse an existing shared widget or theme helper before adding another one.

BAD:

- Guess how a feature works from one widget name and start editing immediately.
- Claim a root cause without reading the code path that actually produces the data or error.
- Replace a distinctive interaction pattern with a generic one without user approval.
- Create `NewProfileService` because the existing service looks inconvenient.
- Add local widget state that duplicates a Riverpod source of truth.
- Work around a protocol limitation by storing fake permanent data only on the client.

## Build And Validation

Run commands from the repository root.

Preferred validation order:

1. Validate changed files first: `flutter analyze <files>`
2. Run focused tests when relevant: `flutter test <target>`
3. Use broader validation only when the task actually needs it

Project commands:

- Install dependencies: `flutter pub get`
- Regenerate localizations: `flutter gen-l10n`
- Regenerate generated Dart code and env bindings: `dart run build_runner build -d`

If `.env` changes, regenerate Envied output with `dart run build_runner build -d`.

GOOD:

- Run `flutter analyze` only for touched files after a focused Dart/UI change.
- Run `flutter gen-l10n` after adding or changing ARB strings.
- Run `dart run build_runner build -d` after changing `freezed`, `json_serializable`, `riverpod`, or `envied` inputs.

BAD:

- Skip regeneration after changing annotated models and then patch generated output by hand.
- Run large validation by default when a targeted check is enough.
- Modify CI because a local command was inconvenient.

## Generated Files And Build Outputs

- Do not hand-edit generated files such as `*.g.dart`, `*.freezed.dart`, `lib/core/config/env.g.dart`, or platform-generated registrant/plugin files unless the task is explicitly about generation or tooling.
- Do not reintroduce CI checks that fail on platform-generated noise alone.
- Regenerate outputs from source inputs instead of patching generated artifacts.

GOOD:

- Edit the annotated source file and rerun generation.
- Treat generated plugin and CMake outputs as derived artifacts.

BAD:

- Patch a `*.g.dart` file because it is faster.
- Add a workflow step that fails whenever local generation order changes in platform-generated files.

## Architecture Rules

- Keep business logic out of presentation widgets when possible.
- Reuse current `AegisAuthService`, `AegisChatService`, protocol DTOs, and client code before adding wrappers.
- Follow Riverpod patterns already used by the repo.
- Keep navigation aligned with `GoRouter` and existing route constants.
- Prefer one clear source of truth for data ownership.

GOOD:

- Let the service own protocol interaction and cache synchronization.
- Keep widgets focused on rendering, user interaction, and thin state wiring.
- Update the current provider or notifier instead of adding a second cache.

BAD:

- Put reconnect logic directly inside a screen widget.
- Add a second in-memory profile map when the service already owns profile data.
- Trigger protocol requests from multiple layers for the same state change without coordination.

## Aegis Protocol Rules

- The server session is bound to the active TCP connection.
- Reconnect, disconnect, restore-session, and login flows must stay serialized.
- Treat `ProfileGet` and `ProfileUpdate` payloads as authoritative only when the response reports success.
- `ChatList` and local conversation seeds are not authoritative profile data.
- If protocol support does not exist, stop at the client boundary and describe the missing contract instead of faking persistence.
- Do not clear stored auth on the first transient authenticated-request failure without checking recovery paths.

GOOD:

- Retry a request through a controlled recovery path if `Not authenticated` can be caused by reconnect timing.
- Use `ProfileGet` for final profile fields when accuracy matters.
- Return an explicit limitation in UI for unsupported fields.

BAD:

- Treat any `Not authenticated` response as immediate proof that the session is permanently invalid.
- Read final profile information from chat list seed data.
- Pretend that a phone number, privacy toggle, or other unsupported field is saved server-side when it is not.

## UI And Product Rules

- Respect the current visual language unless the task explicitly requests redesign.
- Keep unsupported server-backed fields honest in UI.
- Prefer explicit product messaging over silent failure or fake success.
- Preserve localization behavior; when adding user-facing strings, update ARB-based localization flow when practical.

GOOD:

- Show a clear "not available" or "in development" state for unsupported settings.
- Use existing theme helpers, spacing, and widget patterns before inventing new ones.
- Add localized strings through the l10n flow for real UI text.

BAD:

- Leave editable controls enabled for fields the backend cannot persist.
- Hardcode new user-facing strings throughout widgets when they belong in localization.
- Quietly swallow an error and render stale data as if the save succeeded.

## Comments, Naming, And Readability

- Prefer clear naming and structure over explanatory comments.
- Do not add line-by-line or between-line comments that narrate obvious code.
- Comments are allowed only before a non-trivial block when they explain non-obvious constraints, protocol behavior, or tricky control flow.
- If a comment is needed, it should explain the whole block, not annotate each following line.
- Keep functions small enough that their behavior is readable without narration.

GOOD:

- Name a helper `_recoverSessionAndRetry` if that is what it does.
- Add a short comment above a multi-step reconnect block when serialization is required for protocol reasons.
- Remove a redundant inline comment if the code becomes self-explanatory after renaming.

BAD:

- Add line-by-line comments that restate obvious Dart code.
- Insert comments between successive lines such as `// set loading`, `// call service`, `// update state`.
- Hide important protocol assumptions inside vague helper names.

## Design Change Rules

- Do not replace distinctive UI patterns with generic layouts unless the user explicitly asks for redesign.
- Preserve signature navigation structures such as the floating navigation bar and the side navigation layout.
- If a design request conflicts with an established product pattern, stop and confirm before changing it.

GOOD:

- Keep the current navigation shell visible while redesigning the content inside it.
- Improve spacing, hierarchy, and states inside the existing layout system.

BAD:

- Remove the floating nav bar because a simpler scaffold looks easier to build.
- Move core navigation away from its established position without explicit approval.

## When To Stop And Tell The User

- Stop at the boundary if the requested behavior requires server or protocol work outside this repository.
- Stop and surface uncertainty if an unexpected user change conflicts with the requested edit.
- Do not silently revert unrelated modifications.

When blocked by a backend contract, say what the client can safely do now and what remains server-side.

## Change Discipline

- Fix the requested problem first.
- Avoid opportunistic refactors unless they are necessary to make the requested change safe.
- Before finishing, summarize what changed, what was validated, and any remaining limitations.