import 'package:flutter/material.dart';
import '../utils/secure_store.dart';

/// Data class for theme settings
class ThemeSettings {
  final String fontFamily;
  final int primaryColorValue;
  final int fontWeight;

  const ThemeSettings({
    this.fontFamily = 'Inter',
    this.primaryColorValue = 0xFF6200EE,
    this.fontWeight = 4, // Corresponds to FontWeight.w500
  });

  ThemeSettings copyWith({
    String? fontFamily,
    int? primaryColorValue,
    int? fontWeight,
  }) {
    return ThemeSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      fontWeight: fontWeight ?? this.fontWeight,
    );
  }
}

/// Service for managing app settings
///
/// Provides methods to load, save, and notify about changes to settings
/// like theme, pale violet mode, and session timeout.
class SettingsService {
  SettingsService._();

  // Keys for secure storage
  static const _fontKey = 'theme_font_family';
  static const _colorKey = 'theme_primary_color';
  static const _weightKey = 'theme_font_weight';
  static const _paleVioletKey = 'theme_pale_violet';
  static const _sessionTimeoutKey = 'session_timeout_days';

  // Notifiers for reactive UI updates
  static final themeNotifier = ValueNotifier<ThemeSettings>(const ThemeSettings());
  static final paleVioletNotifier = ValueNotifier<bool>(false);
  static final sessionTimeoutDaysNotifier = ValueNotifier<int>(30);

  /// Load all settings from secure storage
  static Future<void> loadSettings() async {
    final font = await SecureStore.read(_fontKey) ?? 'Inter';
    final colorStr = await SecureStore.read(_colorKey);
    final weightStr = await SecureStore.read(_weightKey);
    final paleVioletStr = await SecureStore.read(_paleVioletKey);
    final timeoutStr = await SecureStore.read(_sessionTimeoutKey);

    final color = int.tryParse(colorStr ?? '') ?? 0xFF6200EE;
    final weight = int.tryParse(weightStr ?? '') ?? 4;
    
    themeNotifier.value = ThemeSettings(
      fontFamily: font,
      primaryColorValue: color,
      fontWeight: weight,
    );
    
    paleVioletNotifier.value = paleVioletStr == 'true';
    sessionTimeoutDaysNotifier.value = int.tryParse(timeoutStr ?? '30') ?? 30;
  }

  /// Save font family
  static Future<void> setFont(String font) async {
    await SecureStore.write(_fontKey, font);
    themeNotifier.value = themeNotifier.value.copyWith(fontFamily: font);
  }

  /// Save font weight
  static Future<void> setFontWeight(int weight) async {
    await SecureStore.write(_weightKey, weight.toString());
    themeNotifier.value = themeNotifier.value.copyWith(fontWeight: weight);
  }

  /// Save primary color
  static Future<void> setPrimaryColor(int colorValue) async {
    await SecureStore.write(_colorKey, colorValue.toString());
    themeNotifier.value = themeNotifier.value.copyWith(primaryColorValue: colorValue);
  }

  /// Save pale violet mode
  static Future<void> setPaleVioletMode(bool enabled) async {
    await SecureStore.write(_paleVioletKey, enabled.toString());
    paleVioletNotifier.value = enabled;
  }

  static Future<void> updatePrimaryColor(Color color) => setPrimaryColor(color.value);
  static Future<void> updateFontFamily(String family) => setFont(family);
  static Future<void> updateFontWeight(int weight) => setFontWeight(weight);
  static Future<void> togglePaleViolet() => setPaleVioletMode(!paleVioletNotifier.value);

  static Future<void> setSessionTimeoutDays(int days) async {
    await SecureStore.write(_sessionTimeoutKey, days.toString());
    sessionTimeoutDaysNotifier.value = days;
  }
}
