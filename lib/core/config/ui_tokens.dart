// Shared UI tokens: spacing, corner radii, and some text style helpers
import 'package:flutter/material.dart';

class UITokens {
  // Spacing
  static const double space2XS = 2;
  static const double space3XS = 3;
  static const double spaceXS = 4;
  static const double spaceXsSm = 5;
  static const double spaceXSm = 6;
  static const double spaceSm = 8;
  static const double spaceSmMd = 10;
  static const double space = 12;
  static const double spaceMdSm = 14;
  static const double spaceMd = 16;
  static const double spaceMdLg = 18;
  static const double spaceLg = 20;
  static const double spaceXLg = 24;
  static const double space2XL = 28;
  static const double spaceXL = 32;
  static const double space3XL = 40;
  static const double space4XL = 48;
  static const double space5XL = 60;
  static const double bottomSheetClearance = 100;

  // Radii
  static const double corner2XS = 2;
  static const double cornerXS = 4;
  static const double cornerSm = 8;
  static const double cornerSmMd = 10;
  static const double corner = 12;
  static const double cornerMd = 14;
  static const double cornerLg = 16;
  static const double cornerXLg = 18;
  static const double corner2Lg = 20;
  static const double corner2XLg = 22;
  static const double cornerXL = 24;
  static const double corner2XL = 28;
  static const double corner3XL = 32;
  static const double cornerAvatar = 60;
  static const double cornerPill = 999;

  // Common Card elevation
  static const double cardElevation = 2;

  // Borders and strokes
  static const double borderThin = 1;
  static const double borderThick = 2;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 18;
  static const double iconLg = 20;
  static const double iconXL = 24;
  static const double icon2XL = 32;

  // Common sizes
  static const double dragHandleWidth = 40;
  static const double dragHandleHeight = 4;
  static const double buttonHeight = 48;
  static const double authProviderButtonHeight = 50;
  static const double authSocialIconSize = 32;
  static const double authAvatarPickerSize = 140;
  static const double authHelperTextSize = 12;
  static const double authPrimaryButtonHorizontalPadding = 32;
  static const double authPrimaryButtonVerticalPadding = 16;
  static const double authPresetCardWidth = 208;
  static const double authPresetListHeight = 174;
  static const double authStepCardMinHeight = 392;
  static const double compactButtonWidth = 180;
  static const double compactSheetMaxWidth = 320;
  static const double dialogMaxWidth = 420;
  static const double dialogHorizontalInsetMin = 12;
  static const double dialogHorizontalInsetMax = 28;
  static const double heroCardMaxWidth = 540;
  static const double sheetContentMaxWidth = 560;
  static const double compactFormMaxWidth = 640;
  static const double sectionContentMaxWidth = 760;
  static const double panelContentMaxWidth = 860;
  static const double formContentMaxWidth = 920;
  static const double settingsSidebarWidth = 300;
  static const double settingsInfoBlockWidth = 260;
  static const double wideContentMaxWidth = 1320;
  static const double bottomBarClearance = 120;

  // Validation and profile constraints
  static const int aegisUsernameMinLength = 3;
  static const int aegisUsernameMaxLength = 32;
  static const int authPasswordMinLength = 6;
  static const int profileNameMaxLength = 120;
  static const int profileBioMaxLength = 512;
  static const int profileLocationMaxLength = 120;

  // Responsive breakpoints
  static const double mobileBreakpoint = 540;
  static const double tabletBreakpoint = 760;
  static const double desktopBreakpoint = 1100;
  static const double ultraWideBreakpoint = 1400;
  static const double contentMaxWidth = 1200;
  static const double readableContentMaxWidth = 920;

  // Motion
  static const Duration durationXS = Duration(milliseconds: 120);
  static const Duration duration2XS = Duration(milliseconds: 100);
  static const Duration durationXSm = Duration(milliseconds: 140);
  static const Duration durationSm = Duration(milliseconds: 200);
  static const Duration durationSmMd = Duration(milliseconds: 180);
  static const Duration durationMdSm = Duration(milliseconds: 220);
  static const Duration durationMd = Duration(milliseconds: 260);
  static const Duration durationMdLg = Duration(milliseconds: 240);
  static const Duration durationLgSm = Duration(milliseconds: 300);
  static const Duration durationLgMd = Duration(milliseconds: 350);
  static const Duration durationLg = Duration(milliseconds: 450);
  static const Duration duration2Lg = Duration(milliseconds: 600);
  static const Duration duration3Lg = Duration(milliseconds: 1100);
  static const Duration durationXL = Duration(milliseconds: 700);
  static const Duration duration2XL = Duration(milliseconds: 1400);

  // Helper to create a slightly emphasized text style based on theme
  static TextStyle emphasized(BuildContext context) => Theme.of(
    context,
  ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);

  // ─── text style helpers ──────────────────────────────────────────────

  static TextStyle senderName(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
      );

  static TextStyle messageText(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle timestamp(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
        fontWeight: FontWeight.w500,
      );

  static TextStyle screenTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle sectionHeader(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle subtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      );
}
