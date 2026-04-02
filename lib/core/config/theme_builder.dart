import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class AppThemeBuilder {
  AppThemeBuilder._();

  static ThemeData buildMaterial(
    ThemeSettings settings,
    bool paleVioletEnabled, {
    Brightness? brightnessOverride,
  }) {
    final selectedColorInt = settings.primaryColorValue;
    final brightness =
        brightnessOverride ??
        (Color(selectedColorInt).computeLuminance() > 0.5
            ? Brightness.light
            : Brightness.dark);
    final isLight = brightness == Brightness.light;
    final seedColor = Color(paleVioletEnabled ? 0xFFE8D7FF : selectedColorInt);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      surface: isLight ? const Color(0xFFF8F9FA) : const Color(0xFF090A0B),
      surfaceContainer: isLight
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF131517),
      outlineVariant: isLight
          ? const Color(0xFFE2E8F0)
          : const Color(0xFF272E38),
    );

    final radius = _getRadius(settings.shapeVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: settings.compactMode
          ? VisualDensity.compact
          : VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.getFont(settings.fontFamily).copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius * 1.5),
          ),
        ),
      ),
    );
  }

  static ShadThemeData buildShadcn(
    ThemeSettings settings,
    bool paleVioletEnabled, {
    Brightness? brightnessOverride,
  }) {
    final selectedColorInt = settings.primaryColorValue;
    final brightness =
        brightnessOverride ??
        (Color(selectedColorInt).computeLuminance() > 0.5
            ? Brightness.light
            : Brightness.dark);

    // Use 'slate' as default shadcn theme (works well with any accent color)
    final shadColorScheme = ShadColorScheme.fromName(
      'slate',
      brightness: brightness,
    );

    GoogleFontBuilder fontBuilder;
    switch (settings.fontFamily) {
      case 'Roboto':
        fontBuilder = GoogleFonts.roboto;
      case 'OpenSans':
        fontBuilder = GoogleFonts.openSans;
      case 'Oswald':
        fontBuilder = GoogleFonts.oswald;
      case 'Inter':
        fontBuilder = GoogleFonts.inter;
      default:
        fontBuilder = GoogleFonts.inter;
    }

    return ShadThemeData(
      brightness: brightness,
      colorScheme: shadColorScheme,
      textTheme: ShadTextTheme.fromGoogleFont(fontBuilder),
    );
  }

  static double _getRadius(ShapeVariant variant) {
    switch (variant) {
      case ShapeVariant.expressive:
        return 24;
      case ShapeVariant.compact:
        return 6;
      case ShapeVariant.rounded:
        return 12;
    }
  }
}
