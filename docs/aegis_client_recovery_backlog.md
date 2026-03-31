# Aegis Client Recovery Backlog

Updated: 2026-03-31 (stage 10: moderation scope and invite-link UX aligned with the current Aegis protocol surface)

Status legend:
- `todo` - not started
- `in_progress` - currently being fixed
- `blocked_server` - cannot be completed on client until server changes
- `done` - completed on client

## Critical Transport And Security

| ID | Status | Area | Problem | Notes |
| --- | --- | --- | --- | --- |
| AEGIS-001 | done | handshake | Client expects SPKI server ECDH key, server now returns raw P-256 key | Client now accepts raw and SPKI peer keys |
| AEGIS-002 | done | transport | No TLS support in client Aegis transport | TLS socket path added with platform certificate validation |
| AEGIS-003 | done | security | Client handshake had drifted from the server contract | Client now follows the current server contract with built-in `AppId` / `AppHash` credentials |
| AEGIS-004 | done | config | Missing client env/config flags for Aegis transport | Client config now covers host, port, timeout, masking key, and optional TLS only |
| AEGIS-025 | done | handshake | Updated server requires `AppId` and `AppHash` in handshake | Client now sends official first-party app credentials during every handshake to satisfy `RequireAppCredentials=true` |

## Core Messaging And Sync

| ID | Status | Area | Problem | Notes |
| --- | --- | --- | --- | --- |
| AEGIS-005 | done | groups | Group text send uses channel flow instead of group flow | Client now routes group sends through `GroupMessageSend` |
| AEGIS-006 | done | groups | Group edit/delete use `channel` scope | Client now routes group edit/delete with `scope: group` |
| AEGIS-007 | done | groups | Group history used channel history flow and missed group push type | Client now uses `GroupHistory` and handles `GroupMessageEvent` |
| AEGIS-008 | blocked_server | rooms | Leaving a room is local-only | Client now blocks local-only leave and shows WIP fallback until server handlers exist |
| AEGIS-009 | done | replies | Reply send ignores `replyToId` | Client now sends, syncs, and persists `ReplyToMessageId` |
| AEGIS-010 | in_progress | reactions | Reactions and pinned messages were stubbed | Mutation flow and live events are wired, but cold-start hydration is still incomplete for channels/reactions |
| AEGIS-011 | done | receipts | Delivery/read state is not persisted locally | Drift schema, migration, UTC-safe round-trip, and test added |

## Group And Membership Management

| ID | Status | Area | Problem | Notes |
| --- | --- | --- | --- | --- |
| AEGIS-012 | done | groups | Group members/roles were derived from local guesses | Group settings now load server member summaries and current user role from the server |
| AEGIS-013 | in_progress | groups | Ban/freeze/kick semantics are incomplete | Client now sends moderation updates with the correct room scope, but server-side semantics are still permission-based rather than explicit moderation states |
| AEGIS-014 | done | groups | Member listing endpoint existed but was not wired into client | Client now loads channel/group member summaries from the server |
| AEGIS-015 | done | groups | `showMessageHistory` and join rules were local-only | Client now persists these through `RoomSettingsUpdate` and exposes tri-state room settings in the UI |

## UI And Product Gaps

| ID | Status | Area | Problem | Notes |
| --- | --- | --- | --- | --- |
| AEGIS-016 | done | create group | Picked avatar is not uploaded during group creation | Client now uploads the selected image immediately after room creation via `GroupEdit` avatar flow |
| AEGIS-017 | done | links | Link UI is restricted too aggressively | Client now exposes invite-link copy for private rooms when the server returns `preferredLink` |
| AEGIS-018 | in_progress | fallback UX | Unsupported protocol-dependent features need localized WIP popup | Shared dialog added and wired for room leave/delete paths and reusable across auth/account screens |
| AEGIS-019 | in_progress | auth UX | Unsupported auth flows throw exceptions | Forgot password, change email/phone, and local-only account actions now show WIP dialog; remaining auth placeholders still need review |
| AEGIS-026 | done | room settings UI | Server now supports tri-state `JoinRule` and `HistoryVisibility`, but client only exposes binary toggles | Room and group settings now expose `Public` / `Invite only` / `Approval` and `World readable` / `Joined` / `Invited` states directly |

## Auth And Account

| ID | Status | Area | Problem | Notes |
| --- | --- | --- | --- | --- |
| AEGIS-020 | todo | auth | Session restore stores `identifier:password` fallback token | Remove insecure credential-as-token storage once safe alternative exists |
| AEGIS-021 | blocked_server | auth | Server auth response still returns empty `SessionToken` | `Aegis-main-new` now generates opaque session tokens in the auth service, but `AuthHandler` still sends an empty token back to the client |
| AEGIS-022 | done | account | Password reset/account deletion are unfinished in UI | Password reset and account deletion now use localized WIP dialog instead of silent/no-op flows |

## Quality

| ID | Status | Area | Problem | Notes |
| --- | --- | --- | --- | --- |
| AEGIS-023 | in_progress | tests | No end-to-end style coverage for new handshake/security path | Next step after build/analyze is green |
| AEGIS-024 | in_progress | analysis | Keep repository at `flutter analyze` = 0 issues after each major stage | Validate continuously |

## Server Changes Required For Full Completion

This section must be updated as client work progresses.

- `SERVER-001` Return the already-generated opaque `SessionToken` from `AuthHandler` on password auth and token re-auth flows so the client can stop storing `identifier:password` fallback tokens.
- `SERVER-004` Provide explicit leave operations for channels/groups if the enum values are intended to be usable.
- `SERVER-005` Add a query path to hydrate existing reactions/pins on cold start, especially for channels where current history payloads do not expose pin/reaction snapshots.