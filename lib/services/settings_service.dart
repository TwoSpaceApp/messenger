import 'package:flutter/material.dart';
import '../utils/secure_store.dart';

/// Data class for theme settings
class ThemeSettings {
  final String fontFamily;
  final int primaryColorValue;
  final int fontWeight;
  final double bubbleRounding;
  final bool dynamicBubbles;
  final int navBarHideTimeoutSeconds;
  final bool enableParallax;
  final bool enableFloatingCircles;
  final double floatingCirclesSpeed;
  final double floatingCirclesOpacity;

  const ThemeSettings({
    this.fontFamily = 'Inter',
    this.primaryColorValue = 0xFF6200EE,
    this.fontWeight = 4,
    this.bubbleRounding = 16.0,
    this.dynamicBubbles = true,
    this.navBarHideTimeoutSeconds = 3,
    this.enableParallax = true,
    this.enableFloatingCircles = true,
    this.floatingCirclesSpeed = 1.0,
    this.floatingCirclesOpacity = 0.5,
  });

  ThemeSettings copyWith({
    String? fontFamily,
    int? primaryColorValue,
    int? fontWeight,
    double? bubbleRounding,
    bool? dynamicBubbles,
    int? navBarHideTimeoutSeconds,
    bool? enableParallax,
    bool? enableFloatingCircles,
    double? floatingCirclesSpeed,
    double? floatingCirclesOpacity,
  }) {
    return ThemeSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      fontWeight: fontWeight ?? this.fontWeight,
      bubbleRounding: bubbleRounding ?? this.bubbleRounding,
      dynamicBubbles: dynamicBubbles ?? this.dynamicBubbles,
      navBarHideTimeoutSeconds: navBarHideTimeoutSeconds ?? this.navBarHideTimeoutSeconds,
      enableParallax: enableParallax ?? this.enableParallax,
      enableFloatingCircles: enableFloatingCircles ?? this.enableFloatingCircles,
      floatingCirclesSpeed: floatingCirclesSpeed ?? this.floatingCirclesSpeed,
      floatingCirclesOpacity: floatingCirclesOpacity ?? this.floatingCirclesOpacity,
    );
  }
}

class SettingsService {
  SettingsService._();

  static const _fontKey = 'theme_font_family';
  static const _colorKey = 'theme_primary_color';
  static const _weightKey = 'theme_font_weight';
  static const _bubbleRoundingKey = 'ui_bubble_rounding';
  static const _dynamicBubblesKey = 'ui_dynamic_bubbles';
  static const _navBarTimeoutKey = 'ui_nav_hide_timeout';
  static const _parallaxKey = 'ui_enable_parallax';
  static const _floatingCirclesKey = 'ui_floating_circles';
  static const _floatingCirclesSpeedKey = 'ui_floating_circles_speed';
  static const _floatingCirclesOpacityKey = 'ui_floating_circles_opacity';
  
  // Legacy/Other settings keys
  static const _paleVioletKey = 'theme_pale_violet';
  static const _sessionTimeoutKey = 'security_session_timeout';
  static const _showEmailKey = 'privacy_show_email';
  static const _showPhoneKey = 'privacy_show_phone';
  static const _languageKey = 'app_language';
  static const _textScaleKey = 'app_text_scale';
  static const _autoDownloadKey = 'app_auto_download';
  static const _sendByEnterKey = 'app_send_enter';

  // Theme Notifier
  static final ValueNotifier<ThemeSettings> themeNotifier = 
      ValueNotifier(const ThemeSettings());
      
  // Other Notifiers (restoring missing ones)
  static final ValueNotifier<bool> paleVioletNotifier = ValueNotifier(false);
  static final ValueNotifier<int> sessionTimeoutDaysNotifier = ValueNotifier(30);
  static final ValueNotifier<bool> showEmailNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> showPhoneNotifier = ValueNotifier(false);
  static final ValueNotifier<String> languageNotifier = ValueNotifier('en');
  static final ValueNotifier<double> textScaleNotifier = ValueNotifier(1.0);
  static final ValueNotifier<bool> autoDownloadMediaNotifier = ValueNotifier(true);
  static final ValueNotifier<bool> sendByEnterNotifier = ValueNotifier(true);

  static Future<void> loadSettings() async {
    // Load Theme
    final font = await SecureStore.read(_fontKey) ?? 'Inter';
    final colorStr = await SecureStore.read(_colorKey);
    final weightStr = await SecureStore.read(_weightKey);
    final roundingStr = await SecureStore.read(_bubbleRoundingKey);
    final dynBubblesStr = await SecureStore.read(_dynamicBubblesKey);
    final navTimeoutStr = await SecureStore.read(_navBarTimeoutKey);
    final parallaxStr = await SecureStore.read(_parallaxKey);
    final floatingCirclesStr = await SecureStore.read(_floatingCirclesKey);
    final floatingSpeedStr = await SecureStore.read(_floatingCirclesSpeedKey);
    final floatingOpacityStr = await SecureStore.read(_floatingCirclesOpacityKey);

    themeNotifier.value = ThemeSettings(
      fontFamily: font,
      primaryColorValue: int.tryParse(colorStr ?? '') ?? 0xFF651FFF,
      fontWeight: int.tryParse(weightStr ?? '') ?? 4,
      bubbleRounding: double.tryParse(roundingStr ?? '') ?? 16.0,
      dynamicBubbles: dynBubblesStr != 'false',
      navBarHideTimeoutSeconds: int.tryParse(navTimeoutStr ?? '') ?? 3,
      enableParallax: parallaxStr != 'false',
      enableFloatingCircles: floatingCirclesStr != 'false',
      floatingCirclesSpeed: double.tryParse(floatingSpeedStr ?? '') ?? 1.0,
      floatingCirclesOpacity: double.tryParse(floatingOpacityStr ?? '') ?? 0.5,
    );
    
    // Load Others
    paleVioletNotifier.value = (await SecureStore.read(_paleVioletKey)) == 'true';
    sessionTimeoutDaysNotifier.value = int.tryParse(await SecureStore.read(_sessionTimeoutKey) ?? '') ?? 30;
    showEmailNotifier.value = (await SecureStore.read(_showEmailKey)) == 'true';
    showPhoneNotifier.value = (await SecureStore.read(_showPhoneKey)) == 'true';
    languageNotifier.value = await SecureStore.read(_languageKey) ?? 'en';
    textScaleNotifier.value = double.tryParse(await SecureStore.read(_textScaleKey) ?? '') ?? 1.0;
    autoDownloadMediaNotifier.value = (await SecureStore.read(_autoDownloadKey)) != 'false';
    sendByEnterNotifier.value = (await SecureStore.read(_sendByEnterKey)) != 'false';
  }

  static Future<void> updateTheme({
    String? fontFamily,
    int? primaryColorValue,
    double? bubbleRounding,
    bool? dynamicBubbles,
    int? navBarHideTimeoutSeconds,
    bool? enableParallax,
    int? fontWeight,
    bool? enableFloatingCircles,
    double? floatingCirclesSpeed,
    double? floatingCirclesOpacity,
  }) async {
    final current = themeNotifier.value;
    final next = current.copyWith(
      fontFamily: fontFamily,
      primaryColorValue: primaryColorValue,
      bubbleRounding: bubbleRounding,
      dynamicBubbles: dynamicBubbles,
      navBarHideTimeoutSeconds: navBarHideTimeoutSeconds,
      enableParallax: enableParallax,
      fontWeight: fontWeight,
      enableFloatingCircles: enableFloatingCircles,
      floatingCirclesSpeed: floatingCirclesSpeed,
      floatingCirclesOpacity: floatingCirclesOpacity,
    );
    
    themeNotifier.value = next;

    if (fontFamily != null) await SecureStore.write(_fontKey, fontFamily);
    if (primaryColorValue != null) await SecureStore.write(_colorKey, primaryColorValue.toString());
    if (fontWeight != null) await SecureStore.write(_weightKey, fontWeight.toString());
    if (bubbleRounding != null) await SecureStore.write(_bubbleRoundingKey, bubbleRounding.toString());
    if (dynamicBubbles != null) await SecureStore.write(_dynamicBubblesKey, dynamicBubbles.toString());
    if (navBarHideTimeoutSeconds != null) await SecureStore.write(_navBarTimeoutKey, navBarHideTimeoutSeconds.toString());
    if (enableParallax != null) await SecureStore.write(_parallaxKey, enableParallax.toString());
    if (enableFloatingCircles != null) await SecureStore.write(_floatingCirclesKey, enableFloatingCircles.toString());
    if (floatingCirclesSpeed != null) await SecureStore.write(_floatingCirclesSpeedKey, floatingCirclesSpeed.toString());
    if (floatingCirclesOpacity != null) await SecureStore.write(_floatingCirclesOpacityKey, floatingCirclesOpacity.toString());
  }

  // --- Legacy/Compatibility Methods ---

  static Future<void> updatePrimaryColor(int color) async {
    await updateTheme(primaryColorValue: color);
  }
  
  static Future<void> setPrimaryColor(int color) => updatePrimaryColor(color);

  static Future<void> updateFontFamily(String family) async {
    await updateTheme(fontFamily: family);
  }
  static Future<void> setFont(String family) => updateFontFamily(family);

  static Future<void> updateFontWeight(int weight) async {
    await updateTheme(fontWeight: weight);
  }
  static Future<void> setFontWeight(int weight) => updateFontWeight(weight);

  static Future<void> togglePaleViolet() async {
    final newVal = !paleVioletNotifier.value;
    paleVioletNotifier.value = newVal;
    await SecureStore.write(_paleVioletKey, newVal.toString());
  }
  static Future<void> setPaleVioletMode(bool enabled) async {
    paleVioletNotifier.value = enabled;
    await SecureStore.write(_paleVioletKey, enabled.toString());
  }

  static Future<void> setSessionTimeoutDays(int days) async {
    sessionTimeoutDaysNotifier.value = days;
    await SecureStore.write(_sessionTimeoutKey, days.toString());
  }
  
  static Future<void> setShowEmail(bool val) async {
    showEmailNotifier.value = val;
    await SecureStore.write(_showEmailKey, val.toString());
  }
  
  static Future<void> setShowPhone(bool val) async {
    showPhoneNotifier.value = val;
    await SecureStore.write(_showPhoneKey, val.toString());
  }
  
  static Future<void> setLanguage(String lang) async {
    languageNotifier.value = lang;
    await SecureStore.write(_languageKey, lang);
  }
  
  static Future<void> setTextScale(double scale) async {
    textScaleNotifier.value = scale;
    await SecureStore.write(_textScaleKey, scale.toString());
  }
  
  static Future<void> setAutoDownloadMedia(bool val) async {
    autoDownloadMediaNotifier.value = val;
    await SecureStore.write(_autoDownloadKey, val.toString());
  }
  
  static Future<void> setSendByEnter(bool val) async {
    sendByEnterNotifier.value = val;
    await SecureStore.write(_sendByEnterKey, val.toString());
  }

  static Future<void> clearCachedProfile() async {
    // No-op or implementation if needed
  }
}
