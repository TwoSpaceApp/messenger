import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:two_space_app/core/navigation/app_transitions.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class AppThemeBuilder {
  AppThemeBuilder._();

  static ThemeData build(
    ThemeSettings settings,
    bool paleVioletEnabled, {
    Brightness? brightnessOverride,
  }) {
    final selectedColorInt = settings.primaryColorValue;
    final isLightTheme = (brightnessOverride ??
            (_isLightIntention(selectedColorInt)
                ? Brightness.light
                : Brightness.dark)) ==
        Brightness.light;

    final primaryColor = Color(selectedColorInt);

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
    final errorColor =
        isLightTheme ? const Color(0xFFD32F2F) : const Color(0xFFEF5350);

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

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      visualDensity:
          settings.compactMode ? VisualDensity.compact : VisualDensity.standard,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        onPrimary: Colors.white,
        surface: surfaceColor,
        surfaceContainer: surfaceContainerColor,
        onSurface: onSurfaceColor,
        surfaceContainerHighest: surfaceContainerHighColor,
        secondary: primaryColor,
        outline: outlineColor,
        error: errorColor,
        shadow: isLightTheme
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.25),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        iconTheme: IconThemeData(color: onBackgroundColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
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
      iconTheme: IconThemeData(
        color: onBackgroundColor,
      ),
      listTileTheme: ListTileThemeData(
        dense: settings.compactMode,
        visualDensity:
            settings.compactMode ? VisualDensity.compact : VisualDensity.standard,
      ),
      cardTheme: CardThemeData(
        margin: settings.compactMode
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    const lightColors = [0xFF03A9F4, 0xFF8BC34A, 0xFFE8D7FF, 0xFFFFFFFF];
    return lightColors.contains(colorValue);
  }
}
