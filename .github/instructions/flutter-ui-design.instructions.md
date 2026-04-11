---
description: "Use when changing Flutter UI, screens, widgets, layouts, navigation chrome, themes, visual styling, responsive behavior, or localization-backed interface text in TwoSpace."
applyTo: "lib/features/**/presentation/**/*.dart, lib/core/widgets/**/*.dart, lib/core/router/**/*.dart, lib/core/theme/**/*.dart, lib/core/config/theme_builder.dart"
---

# Flutter UI And Design Instructions

## Scope

- Applies when changing screens, presentation widgets, navigation chrome, visual styling, responsive layout behavior, and user-facing UI text.
- Preserve the current product identity unless the user explicitly asks for a redesign.

## Navigation And Shell Layout

- The floating navigation bar is a signature UI element and must remain visible.
- The left or right navigation layout is part of the product shell and must remain visible.
- Treat most screens as content nested inside the central content area framed by the navigation shell.
- Do not flatten the app into a generic full-screen page flow unless the user explicitly requests a structural redesign.

GOOD:

- Redesign the content card, header, or sections inside the existing shell.
- Keep navigation visible while changing the center content hierarchy.

BAD:

- Hide or remove the floating nav bar during normal screen states.
- Turn a nested center screen into a disconnected full-screen page that ignores the app shell.

## Layout And Responsiveness

- Layouts must adapt cleanly to phone, tablet, desktop, and narrow window sizes.
- Avoid overflow, clipped controls, off-screen actions, and fixed assumptions about width or height.
- Use flexible layout primitives such as `Expanded`, `Flexible`, `LayoutBuilder`, constrained widths, and scrolling where appropriate.
- Test the mental model for narrow and wide screens before finalizing a layout.

GOOD:

- Constrain wide content and let the center area scale gracefully.
- Wrap long columns in scrollable containers when content can exceed the viewport.
- Let actions reflow or stack when horizontal space is limited.

BAD:

- Hardcode a width that breaks on small screens.
- Assume text, avatars, and buttons will always fit in one row.
- Leave a layout that can render Flutter overflow warnings.

## UI Tokens And Spacing

- Use the app's existing theme, tokens, shared spacing, radius, color, and typography helpers.
- Do not introduce raw magic numbers for spacing, sizes, radii, icon sizes, or layout offsets when a token or shared constant should exist.
- If a new reusable size or spacing value is needed, add it in the appropriate shared place instead of scattering hardcoded numbers.

GOOD:

- Reuse shared paddings, section gaps, and typography from the existing theme system.
- Promote a repeated size into a shared token when it becomes part of the UI language.

BAD:

- Scatter literals like `13`, `18`, `27`, or `41` across one screen with no shared meaning.
- Recreate button, card, or section spacing ad hoc in each widget.

## Localization

- All user-visible interface text must go through l10n.
- Do not hardcode screen titles, labels, placeholders, hints, button text, empty states, error text, or banners in widgets.
- If a design change introduces new copy, update localization inputs as part of the change when practical.

GOOD:

- Add a new ARB key for a new empty state or CTA.
- Reuse an existing localized string when the wording already exists.

BAD:

- Leave English or Russian literals inline in a widget tree.
- Add temporary hardcoded UI text with the intention to localize it later.

## States And Feedback

- Loading, empty, error, and success states should look intentional and remain inside the existing shell.
- Unsupported or server-limited settings must be presented honestly.
- Do not fake successful saves or hide important failures.

GOOD:

- Show a clear unsupported-state description for server-limited settings.
- Keep error and retry UI inside the screen layout instead of dropping the user into a blank state.

BAD:

- Show editable inputs for settings that cannot be persisted.
- Swallow an error and leave stale UI looking current.

## Design Change Discipline

- Before changing an unusual or distinctive interface solution, confirm it in simple Russian unless the user explicitly requested that redesign.
- Prefer unification over simplification: keep important product ideas, but bring them into one visual system.
- Improve hierarchy, spacing, and clarity before replacing the underlying interaction model.

## Avoid

- Do not remove signature navigation elements.
- Do not hardcode UI text.
- Do not rely on magic numbers where shared tokens should exist.
- Do not leave overflow-prone layouts unresolved.