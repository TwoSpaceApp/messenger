import 'package:flutter/material.dart';
import 'package:two_space_app/services/settings_service.dart';

class AppThemeBuilder {
  AppThemeBuilder._();

  static ThemeData build(ThemeSettings settings, bool paleVioletEnabled) {
    // Force Element-like dark theme
    const primaryColor = Color(0xFF0DBD8B);
    const backgroundColor = Color(0xFF1D2227);
    const surfaceColor = Color(0xFF21262C);
    const onPrimaryColor = Colors.black;
    const onSurfaceColor = Colors.white;

    final baseTheme = ThemeData.dark();

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        onPrimary: onPrimaryColor,
        onSecondary: onPrimaryColor,
        onBackground: onSurfaceColor,
        onSurface: onSurfaceColor,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(baseTheme.textTheme, onSurfaceColor),
      inputDecorationTheme: _buildInputTheme(surfaceColor),
      elevatedButtonTheme: _buildButtonTheme(primaryColor, onPrimaryColor),
      textButtonTheme: _buildTextButtonTheme(primaryColor),
      listTileTheme: const ListTileThemeData(
        selectedColor: primaryColor,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF151718),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color onSurfaceColor) {
    return base.apply(
      fontFamily: 'Inter',
      bodyColor: onSurfaceColor,
      displayColor: onSurfaceColor,
    );
  }

  static InputDecorationTheme _buildInputTheme(Color surfaceColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme(Color primary, Color onPrimary) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Color primary) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    );
  }
}
