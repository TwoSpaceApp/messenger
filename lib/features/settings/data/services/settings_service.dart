import 'package:flutter/material.dart';
import 'package:two_space_app/core/utils/secure_store.dart';

enum MessageTimestampPrecision { minutes, seconds, milliseconds }

extension MessageTimestampPrecisionX on MessageTimestampPrecision {
  String get storageValue {
    switch (this) {
      case MessageTimestampPrecision.minutes:
        return 'minutes';
      case MessageTimestampPrecision.seconds:
        return 'seconds';
      case MessageTimestampPrecision.milliseconds:
        return 'milliseconds';
    }
  }

  static MessageTimestampPrecision fromStorage(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'seconds':
        return MessageTimestampPrecision.seconds;
      case 'milliseconds':
        return MessageTimestampPrecision.milliseconds;
      case 'minutes':
      default:
        return MessageTimestampPrecision.minutes;
    }
  }
}

/// Data class for theme settings
class ThemeSettings {
  final String fontFamily;
  final int primaryColorValue;
  final int fontWeight;
  final double bubbleRounding;
  final bool dynamicBubbles;
  final bool compactMode;
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
    this.compactMode = false,
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
    bool? compactMode,
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
      compactMode: compactMode ?? this.compactMode,
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
  static const _compactModeKey = 'ui_compact_mode';
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
  static const _themeModeKey = 'app_theme_mode';
  static const _messageTimestampPrecisionKey = 'chat_message_timestamp_precision';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _soundEnabledKey = 'notifications_sound_enabled';
  static const _doNotDisturbKey = 'notifications_do_not_disturb';
  static const _biometricsKey = 'biometric_enabled';

  // Theme Notifier
  static final ValueNotifier<ThemeSettings> themeNotifier = 
      ValueNotifier(const ThemeSettings());
      
  // Other Notifiers (restoring missing ones)
  static final ValueNotifier<bool> paleVioletNotifier = ValueNotifier(false);
  static final ValueNotifier<int> sessionTimeoutDaysNotifier = ValueNotifier(30);
  static final ValueNotifier<bool> showEmailNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> showPhoneNotifier = ValueNotifier(false);
  static final ValueNotifier<String> languageNotifier = ValueNotifier('en');
  static final ValueNotifier<double> textScaleNotifier = ValueNotifier(1);
  static final ValueNotifier<bool> autoDownloadMediaNotifier = ValueNotifier(true);
  static final ValueNotifier<bool> sendByEnterNotifier = ValueNotifier(true);
  static final ValueNotifier<MessageTimestampPrecision>
      messageTimestampPrecisionNotifier =
      ValueNotifier(MessageTimestampPrecision.minutes);
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<bool> biometricsNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> notificationsEnabledNotifier = ValueNotifier(true);
  static final ValueNotifier<bool> soundEnabledNotifier = ValueNotifier(true);
  static final ValueNotifier<bool> doNotDisturbNotifier = ValueNotifier(false);

  static Future<void> loadSettings() async {
    final stored = await SecureStore.readAll();

    String? valueOf(String key) => stored[key];

    themeNotifier.value = ThemeSettings(
      fontFamily: valueOf(_fontKey) ?? 'Inter',
      primaryColorValue: int.tryParse(valueOf(_colorKey) ?? '') ?? 0xFF651FFF,
      fontWeight: int.tryParse(valueOf(_weightKey) ?? '') ?? 4,
      bubbleRounding: double.tryParse(valueOf(_bubbleRoundingKey) ?? '') ?? 16.0,
      dynamicBubbles: valueOf(_dynamicBubblesKey) != 'false',
      compactMode: valueOf(_compactModeKey) == 'true',
      navBarHideTimeoutSeconds: int.tryParse(valueOf(_navBarTimeoutKey) ?? '') ?? 3,
      enableParallax: valueOf(_parallaxKey) != 'false',
      enableFloatingCircles: valueOf(_floatingCirclesKey) != 'false',
      floatingCirclesSpeed: double.tryParse(valueOf(_floatingCirclesSpeedKey) ?? '') ?? 1.0,
      floatingCirclesOpacity: double.tryParse(valueOf(_floatingCirclesOpacityKey) ?? '') ?? 0.5,
    );
    
    // Load Others
    paleVioletNotifier.value = valueOf(_paleVioletKey) == 'true';
    sessionTimeoutDaysNotifier.value = int.tryParse(valueOf(_sessionTimeoutKey) ?? '') ?? 30;
    showEmailNotifier.value = valueOf(_showEmailKey) == 'true';
    showPhoneNotifier.value = valueOf(_showPhoneKey) == 'true';
    languageNotifier.value = valueOf(_languageKey) ?? 'en';
    textScaleNotifier.value = double.tryParse(valueOf(_textScaleKey) ?? '') ?? 1.0;
    autoDownloadMediaNotifier.value = valueOf(_autoDownloadKey) != 'false';
    sendByEnterNotifier.value = valueOf(_sendByEnterKey) != 'false';
    messageTimestampPrecisionNotifier.value =
        MessageTimestampPrecisionX.fromStorage(
      valueOf(_messageTimestampPrecisionKey),
    );

    // Theme mode (system/light/dark)
    themeModeNotifier.value = _themeModeFromString(valueOf(_themeModeKey));

    final bioStr = valueOf(_biometricsKey) ?? valueOf('biometrics_enabled');
    biometricsNotifier.value = (bioStr == 'true');
    notificationsEnabledNotifier.value =
        valueOf(_notificationsEnabledKey) != 'false';
    soundEnabledNotifier.value =
        valueOf(_soundEnabledKey) != 'false';
    doNotDisturbNotifier.value =
        valueOf(_doNotDisturbKey) == 'true';
  }

  static Future<void> setBiometricsEnabled(bool value) async {
    await SecureStore.write(_biometricsKey, value.toString());
    await SecureStore.write('biometrics_enabled', value.toString());
    biometricsNotifier.value = value;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabledNotifier.value = value;
    await SecureStore.write(_notificationsEnabledKey, value.toString());
    if (!value && soundEnabledNotifier.value) {
      await setSoundEnabled(false);
    }
  }

  static Future<void> setSoundEnabled(bool value) async {
    soundEnabledNotifier.value = value;
    await SecureStore.write(_soundEnabledKey, value.toString());
    if (value && !notificationsEnabledNotifier.value) {
      await setNotificationsEnabled(true);
    }
  }

  static Future<void> setDoNotDisturb(bool value) async {
    doNotDisturbNotifier.value = value;
    await SecureStore.write(_doNotDisturbKey, value.toString());
  }

  static ThemeMode _themeModeFromString(String? v) {
    switch ((v ?? '').trim().toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await SecureStore.write(_themeModeKey, _themeModeToString(mode));
  }

  static Future<void> updateTheme({
    String? fontFamily,
    int? primaryColorValue,
    double? bubbleRounding,
    bool? dynamicBubbles,
    bool? compactMode,
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
      compactMode: compactMode,
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
    if (compactMode != null) await SecureStore.write(_compactModeKey, compactMode.toString());
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

  static Future<void> setCompactMode(bool value) async {
    await updateTheme(compactMode: value);
  }
  
  static Future<void> setAutoDownloadMedia(bool val) async {
    autoDownloadMediaNotifier.value = val;
    await SecureStore.write(_autoDownloadKey, val.toString());
  }
  
  static Future<void> setSendByEnter(bool val) async {
    sendByEnterNotifier.value = val;
    await SecureStore.write(_sendByEnterKey, val.toString());
  }

  static Future<void> setMessageTimestampPrecision(
    MessageTimestampPrecision precision,
  ) async {
    messageTimestampPrecisionNotifier.value = precision;
    await SecureStore.write(
      _messageTimestampPrecisionKey,
      precision.storageValue,
    );
  }

  static Future<void> clearCachedProfile() async {
    // No-op or implementation if needed
  }
}
