import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_space_app/core/navigation/app_transitions.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class AppThemeBuilder {
  AppThemeBuilder._();

  static FontWeight _resolveFontWeight(int weight) {
    switch (weight.clamp(300, 900)) {
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  static int _offsetWeight(int base, int delta) =>
      (base + delta).clamp(300, 900);

  static TextTheme _applyFontWeights(TextTheme textTheme, int baseWeight) {
    TextStyle? weighted(TextStyle? style, int resolvedWeight) {
      if (style == null) return null;
      return style.copyWith(fontWeight: _resolveFontWeight(resolvedWeight));
    }

    return textTheme.copyWith(
      displayLarge: weighted(
        textTheme.displayLarge,
        _offsetWeight(baseWeight, 300),
      ),
      displayMedium: weighted(
        textTheme.displayMedium,
        _offsetWeight(baseWeight, 300),
      ),
      displaySmall: weighted(
        textTheme.displaySmall,
        _offsetWeight(baseWeight, 200),
      ),
      headlineLarge: weighted(
        textTheme.headlineLarge,
        _offsetWeight(baseWeight, 200),
      ),
      headlineMedium: weighted(
        textTheme.headlineMedium,
        _offsetWeight(baseWeight, 200),
      ),
      headlineSmall: weighted(
        textTheme.headlineSmall,
        _offsetWeight(baseWeight, 100),
      ),
      titleLarge: weighted(
        textTheme.titleLarge,
        _offsetWeight(baseWeight, 100),
      ),
      titleMedium: weighted(
        textTheme.titleMedium,
        _offsetWeight(baseWeight, 100),
      ),
      titleSmall: weighted(
        textTheme.titleSmall,
        _offsetWeight(baseWeight, 100),
      ),
      bodyLarge: weighted(textTheme.bodyLarge, baseWeight),
      bodyMedium: weighted(textTheme.bodyMedium, baseWeight),
      bodySmall: weighted(textTheme.bodySmall, baseWeight),
      labelLarge: weighted(
        textTheme.labelLarge,
        _offsetWeight(baseWeight, 100),
      ),
      labelMedium: weighted(
        textTheme.labelMedium,
        _offsetWeight(baseWeight, 100),
      ),
      labelSmall: weighted(
        textTheme.labelSmall,
        _offsetWeight(baseWeight, 100),
      ),
    );
  }

  static ThemeData buildMaterial(
    ThemeSettings settings,
    bool paleVioletEnabled, {
    Brightness? brightnessOverride,
  }) {
    final selectedColorInt = settings.primaryColorValue;
    final isLightTheme =
        (brightnessOverride ??
                (_isLightIntention(selectedColorInt)
                    ? Brightness.light
                    : Brightness.dark)) ==
            Brightness.light;

    final primaryColor = Color(
      paleVioletEnabled ? 0xFFE8D7FF : selectedColorInt,
    );

    final backgroundColor =
        isLightTheme ? const Color(0xFFF5F7FA) : const Color(0xFF0F1115);
    final surfaceColor =
        isLightTheme ? const Color(0xFFFFFFFF) : const Color(0xFF1D2227);
    final surfaceContainerColor =
        isLightTheme ? const Color(0xFFF0F2F5) : const Color(0xFF272C31);
    final surfaceContainerHighColor =
        isLightTheme ? const Color(0xFFE8EBF0) : const Color(0xFF2E3338);
    final onBackgroundColor = isLightTheme ? Colors.black87 : Colors.white;
    final onSurfaceColor = isLightTheme ? Colors.black87 : Colors.white;
    final outlineColor = isLightTheme
        ? Colors.black.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.25);
    final outlineVariantColor = isLightTheme
        ? const Color(0xFFD7DEE7)
        : const Color(0xFF3A4048);
    final onSurfaceVariantColor =
        isLightTheme ? const Color(0xFF55606D) : Colors.white70;
    final errorColor =
        isLightTheme ? const Color(0xFFD32F2F) : const Color(0xFFEF5350);
    final tertiaryColor =
        isLightTheme ? const Color(0xFF2E8BFF) : const Color(0xFF74B1FF);
    final primaryContainerColor = isLightTheme
        ? Color.lerp(primaryColor, Colors.white, 0.82)!
        : primaryColor.withValues(alpha: 0.24);
    final onPrimaryContainerColor = isLightTheme
        ? const Color(0xFF17365D)
        : Colors.white;

    final baseTheme = isLightTheme ? ThemeData.light() : ThemeData.dark();

    final mainTextTheme = baseTheme.textTheme.apply(
      bodyColor: onBackgroundColor,
      displayColor: onBackgroundColor,
    );

    TextTheme textTheme;
    final fontName = settings.fontFamily;

    if (fontName == 'Roboto') {
      textTheme = GoogleFonts.robotoTextTheme(mainTextTheme);
    } else if (fontName == 'NotoSans') {
      textTheme = GoogleFonts.notoSansTextTheme(mainTextTheme);
    } else if (fontName == 'OpenSans') {
      textTheme = GoogleFonts.openSansTextTheme(mainTextTheme);
    } else if (fontName == 'Oswald') {
      textTheme = GoogleFonts.oswaldTextTheme(mainTextTheme);
    } else if (fontName == 'PressStart 2P') {
      textTheme = GoogleFonts.pressStart2pTextTheme(mainTextTheme);
    } else if (fontName == 'ComicSans MS') {
      textTheme = GoogleFonts.comicNeueTextTheme(mainTextTheme);
    } else {
      textTheme = GoogleFonts.interTextTheme(mainTextTheme);
    }

    textTheme = _applyFontWeights(
      textTheme,
      SettingsService.normalizeFontWeight(settings.fontWeight),
    );

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      visualDensity: settings.compactMode
          ? VisualDensity.compact
          : VisualDensity.standard,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryContainerColor,
        onPrimaryContainer: onPrimaryContainerColor,
        surface: surfaceColor,
        surfaceContainer: surfaceContainerColor,
        onSurface: onSurfaceColor,
        onSurfaceVariant: onSurfaceVariantColor,
        surfaceContainerHighest: surfaceContainerHighColor,
        secondary: primaryColor,
        tertiary: tertiaryColor,
        outline: outlineColor,
        outlineVariant: outlineVariantColor,
        error: errorColor,
        surfaceTint: primaryColor,
        shadow: isLightTheme
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.25),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        iconTheme: IconThemeData(color: onBackgroundColor),
      ),
      dividerColor: outlineVariantColor,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLightTheme ? const Color(0xFFF7FAFD) : surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: onBackgroundColor.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: onBackgroundColor.withValues(alpha: 0.4)),
      ),
      iconTheme: IconThemeData(color: onBackgroundColor),
      listTileTheme: ListTileThemeData(
        dense: settings.compactMode,
        visualDensity: settings.compactMode
            ? VisualDensity.compact
            : VisualDensity.standard,
      ),
      cardTheme: CardThemeData(
        margin: settings.compactMode
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: surfaceColor,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.linux: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
          TargetPlatform.windows: AppPageTransitionsBuilder(),
          TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
        },
      ),
    );
  }

  static bool _isLightIntention(int colorValue) {
    const lightColors = [0xFF03A9F4, 0xFF8BC34A, 0xFFE8D7FF, 0xFFFFB300];
    return lightColors.contains(colorValue);
  }
}
