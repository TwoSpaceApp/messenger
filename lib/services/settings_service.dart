import 'package:flutter/material.dart';
import 'dart:convert';
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
  static const _paleVioletModeKey = 'theme_pale_violet';
  static const _sessionTimeoutKey = 'session_timeout_days';
  
  static const _chatListOnRightKey = 'ui_chat_list_right';
  static const _chatListWidthKey = 'ui_chat_list_width';
  static const _showEmailKey = 'profile_show_email';
  static const _showPhoneKey = 'profile_show_phone';
  static const _cachedProfileKey = 'auth_cached_profile';

  // Notifiers for reactive UI updates
  static final themeNotifier = ValueNotifier<ThemeSettings>(const ThemeSettings());
  static final paleVioletNotifier = ValueNotifier<bool>(false);
  static final sessionTimeoutDaysNotifier = ValueNotifier<int>(30);
  
  static final chatListOnRightNotifier = ValueNotifier<bool>(false);
  static final chatListWidthNotifier = ValueNotifier<double>(360.0);
  static final showEmailNotifier = ValueNotifier<bool>(false);
  static final showPhoneNotifier = ValueNotifier<bool>(false);

  // Additional settings
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('ru');
  static const _languageKey = 'app_language';
  
  static final ValueNotifier<double> textScaleNotifier = ValueNotifier<double>(1.0);
  static const _textScaleKey = 'ui_text_scale';
  
  static final ValueNotifier<bool> autoDownloadMediaNotifier = ValueNotifier<bool>(false);
  static const _autoDownloadMediaKey = 'auto_download_media';
  
  static final ValueNotifier<bool> sendByEnterNotifier = ValueNotifier<bool>(true);
  static const _sendByEnterKey = 'send_by_enter';
  
  static final ValueNotifier<bool> compactModeNotifier = ValueNotifier<bool>(false);
  static const _compactModeKey = 'ui_compact_mode';

  static Future<void> load() async {
    final font = await SecureStore.read(_fontKey) ?? 'Inter';
    final colorStr = await SecureStore.read(_colorKey);
    final color = colorStr != null ? int.tryParse(colorStr) ?? 0xFF7C4DFF : 0xFF7C4DFF;
    final weightStr = await SecureStore.read(_weightKey);
    final weight = weightStr != null ? int.tryParse(weightStr) ?? 400 : 400;
    themeNotifier.value = ThemeSettings(fontFamily: font, primaryColorValue: color, fontWeight: weight);
  final timeoutStr = await SecureStore.read(_sessionTimeoutKey);
  final timeout = timeoutStr != null ? int.tryParse(timeoutStr) ?? 180 : 180;
  sessionTimeoutDaysNotifier.value = timeout;
    final pv = await SecureStore.read(_paleVioletModeKey);
    // If set to '1' it means Pale Violet light-mode is enabled
    final enabled = pv != null && pv == '1';
    paleVioletNotifier.value = enabled;
    // chat list position
    final chatRight = await SecureStore.read(_chatListOnRightKey);
    chatListOnRightNotifier.value = chatRight != null && chatRight == '1';
    // chat list width
    final chatWidth = await SecureStore.read(_chatListWidthKey);
    if (chatWidth != null) {
      final w = double.tryParse(chatWidth) ?? 360;
      chatListWidthNotifier.value = w;
    }
    // profile visibility
    final showEmail = await SecureStore.read(_showEmailKey);
    showEmailNotifier.value = showEmail != null && showEmail == '1';
    final showPhone = await SecureStore.read(_showPhoneKey);
    showPhoneNotifier.value = showPhone != null && showPhone == '1';
    
    // additional settings
    final lang = await SecureStore.read(_languageKey) ?? 'ru';
    languageNotifier.value = lang;
    
    final textScaleStr = await SecureStore.read(_textScaleKey);
    if (textScaleStr != null) {
      final ts = double.tryParse(textScaleStr) ?? 1.0;
      textScaleNotifier.value = ts;
    }
    
    final autoDownload = await SecureStore.read(_autoDownloadMediaKey);
    autoDownloadMediaNotifier.value = autoDownload != null && autoDownload == '1';
    
    final sendByEnter = await SecureStore.read(_sendByEnterKey);
    sendByEnterNotifier.value = sendByEnter == null || sendByEnter == '1'; // default true
    
    final compactMode = await SecureStore.read(_compactModeKey);
    compactModeNotifier.value = compactMode != null && compactMode == '1';
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
    themeNotifier.value = ThemeSettings(fontFamily: themeNotifier.value.fontFamily, primaryColorValue: colorValue, fontWeight: themeNotifier.value.fontWeight);
  }

  static Future<void> updatePrimaryColor(Color color) => setPrimaryColor(color.value);
  static Future<void> updateFontFamily(String family) => setFont(family);
  static Future<void> updateFontWeight(int weight) => setFontWeight(weight);
  static Future<void> togglePaleViolet() => setPaleVioletMode(!paleVioletNotifier.value);

  static Future<void> setSessionTimeoutDays(int days) async {
    await SecureStore.write(_sessionTimeoutKey, days.toString());
    sessionTimeoutDaysNotifier.value = days;
  }

  /// Save pale violet mode
  static Future<void> setPaleVioletMode(bool enabled) async {
    await SecureStore.write(_paleVioletModeKey, enabled.toString());
    paleVioletNotifier.value = enabled;
  }

  static Future<void> saveCachedProfile(Map<String, dynamic> profile) async {
    try {
      final s = jsonEncode(profile);
      await SecureStore.write(_cachedProfileKey, s);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> readCachedProfile() async {
    try {
      final s = await SecureStore.read(_cachedProfileKey);
      if (s == null) return null;
      final parsed = jsonDecode(s);
      if (parsed is Map<String, dynamic>) return parsed;
    } catch (_) {}
    return null;
  }

  static Future<void> updateTheme({int? primaryColorValue, String? fontFamily}) async {
    int color = primaryColorValue ?? themeNotifier.value.primaryColorValue;
    String font = fontFamily ?? themeNotifier.value.fontFamily;
    
    await SecureStore.write(_colorKey, color.toString());
    await SecureStore.write(_fontKey, font);
    
    themeNotifier.value = ThemeSettings(
      fontFamily: font,
      primaryColorValue: color,
      fontWeight: themeNotifier.value.fontWeight
    );
  }

  static Future<void> clearCachedProfile() async {
    try {
      await SecureStore.delete(_cachedProfileKey);
    } catch (_) {}
  }

  // New settings methods
  static Future<void> setLanguage(String lang) async {
    await SecureStore.write(_languageKey, lang);
    languageNotifier.value = lang;
  }

  static Future<void> setTextScale(double scale) async {
    await SecureStore.write(_textScaleKey, scale.toString());
    textScaleNotifier.value = scale;
  }

  static Future<void> setAutoDownloadMedia(bool enabled) async {
    await SecureStore.write(_autoDownloadMediaKey, enabled ? '1' : '0');
    autoDownloadMediaNotifier.value = enabled;
  }

  static Future<void> setSendByEnter(bool enabled) async {
    await SecureStore.write(_sendByEnterKey, enabled ? '1' : '0');
    sendByEnterNotifier.value = enabled;
  }

  static Future<void> setCompactMode(bool enabled) async {
    await SecureStore.write(_compactModeKey, enabled ? '1' : '0');
    compactModeNotifier.value = enabled;
  }
}
