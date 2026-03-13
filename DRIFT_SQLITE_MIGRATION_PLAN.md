# Drift + SQLite Migration Plan

Статус: в работе

## Phase 0. Preparation

- [x] Audit current chat storage and confirm the target stack.
- [x] Confirm Drift and SQLite dependencies already exist in the project.
- [x] Add any missing runtime support packages for Drift on Flutter platforms.

## Phase 1. Database Foundation

- [x] Create a dedicated Drift database for chat storage.
- [x] Define schema for conversations, messages, profiles, and metadata.
- [x] Generate Drift code and confirm clean analyzer output.

## Phase 2. Legacy Data Migration

- [x] Implement import from legacy `aegis_chat_store.json`.
- [x] Implement import from split JSON store (`conversations.json`, `profiles.json`, `messages/`).
- [x] Add an idempotent migration guard so import runs only once.
- [x] Preserve compatibility with existing media files and media cache paths.

## Phase 3. Service Integration

- [x] Replace JSON-backed reads in `AegisChatService` with Drift-backed reads.
- [x] Replace JSON-backed writes and flush logic with Drift upserts/deletes.
- [x] Keep current in-memory behavior and chat/message streams intact.
- [x] Remove obsolete JSON persistence code paths after Drift integration is stable.

## Phase 4. Follow-up Storage Cleanup

- [x] Migrate `OfflineQueueService` from in-memory stub to Drift storage.
- [x] Re-evaluate People/Call history storage for future consolidation.
- [x] Decide whether to delete legacy JSON files automatically after successful migration.
	Policy: keep legacy JSON files as fallback backup; do not delete automatically.

## Phase 5. Validation

- [x] Run `flutter pub get` if dependencies changed.
- [x] Run code generation for Drift.
- [x] Run analyzer on touched files after each major phase.
- [x] Resolve every analyzer issue introduced during migration.
- [x] Finish with zero analyzer issues in changed files.

## Current Focus

1. Validate the wider integration end-to-end.
2. Verify People/Call history migration behavior against existing flows.
3. Keep legacy JSON cleanup as a manual, explicit follow-up if needed.