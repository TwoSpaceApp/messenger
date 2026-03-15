import 'package:flutter/material.dart';

/// Semantic colour tokens that adapt to the current [Brightness].
///
/// Usage: `AppColors.onlineStatus(context)` or the static helpers that take
/// a [BuildContext] and resolve through [Theme.of].
class AppColors {
  AppColors._();

  // ─── helpers ────────────────────────────────────────────────────────

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ─── presence / status ──────────────────────────────────────────────

  static Color onlineStatus(BuildContext context) =>
      _isDark(context) ? const Color(0xFF4CD964) : const Color(0xFF2E7D32);

  static Color recentlyStatus(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFD54F) : const Color(0xFFF9A825);

  static Color offlineStatus(BuildContext context) =>
      _isDark(context) ? Colors.white60 : Colors.black45;

  // ─── message bubbles ────────────────────────────────────────────────

  static Color ownBubble(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color otherBubble(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF2E3338)
          : const Color(0xFFE8EDF2);

  static Color ownBubbleText(BuildContext context) =>
      _isDark(context) ? Colors.white : Colors.white;

  static Color otherBubbleText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  // ─── surfaces & containers ──────────────────────────────────────────

  static Color chipBackground(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

  static Color chipText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color cardOverlay(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);

  static Color reactionBackground(BuildContext context) =>
      _isDark(context)
          ? const Color(0xFF21262C)
          : const Color(0xFFE0E4E8);

  static Color skeletonBase(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

  static Color skeletonHighlight(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.16);

  // ─── icons & text ───────────────────────────────────────────────────

  static Color headerText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color subtitleText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);

  static Color hintText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

  static Color iconDefault(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color iconMuted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

  // ─── destructive / accent ───────────────────────────────────────────

  static Color danger(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color recording(BuildContext context) =>
      _isDark(context) ? Colors.redAccent : Colors.red;

  static Color favoriteActive(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFFD740) : const Color(0xFFFFA000);

  static Color favoriteInactive(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

  // ─── dividers / shadows ─────────────────────────────────────────────

  static Color shadow(BuildContext context) =>
      _isDark(context)
          ? Colors.black.withValues(alpha: 0.25)
          : Colors.black.withValues(alpha: 0.08);

  static Color divider(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

  // ─── media containers ─────────────────────────────────────────────────

  static Color mediaSurface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF171A1F) : const Color(0xFFF0F2F5);

  static Color mediaPlaceholder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF21262C) : const Color(0xFFE0E4E8);

  static Color mediaBorder(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

  // ─── date separator ─────────────────────────────────────────────────

  static Color dateSeparatorBg(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

  static Color dateSeparatorText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

  // ─── dynamic background / glass ────────────────────────────────────

  static Color backgroundGradientStart(BuildContext context) =>
      _isDark(context) ? const Color(0xFF0F1115) : const Color(0xFFF9FBFF);

  static Color backgroundGradientEnd(BuildContext context) =>
      _isDark(context) ? const Color(0xFF171C23) : const Color(0xFFEEF3F8);

  static Color backgroundBlobPrimary(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return _isDark(context)
        ? primary
        : Color.lerp(primary, Colors.white, 0.38) ?? primary;
  }

  static Color backgroundBlobSecondary(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return _isDark(context)
        ? secondary
        : Color.lerp(secondary, const Color(0xFFE8F4FF), 0.46) ?? secondary;
  }

  static Color glassSurface(BuildContext context) =>
      Theme.of(context).colorScheme.surface.withValues(
        alpha: _isDark(context) ? 0.72 : 0.9,
      );

  static Color glassBorder(BuildContext context) =>
      Theme.of(context).colorScheme.outline.withValues(
        alpha: _isDark(context) ? 0.12 : 0.1,
      );

  static Color glassShadow(BuildContext context) =>
      _isDark(context)
          ? Colors.black.withValues(alpha: 0.22)
          : Colors.black.withValues(alpha: 0.06);

  static Color presenceRing(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
}
