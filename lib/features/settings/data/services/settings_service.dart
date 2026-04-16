import 'dart:async';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/utils/secure_store.dart';

enum MessageTimestampPrecision { minutes, seconds, milliseconds }

enum BackgroundMotionMode { circles, waves }

extension BackgroundMotionModeX on BackgroundMotionMode {
  String get storageValue {
    switch (this) {
      case BackgroundMotionMode.circles:
        return 'circles';
      case BackgroundMotionMode.waves:
        return 'waves';
    }
  }

  static BackgroundMotionMode fromStorage(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'waves':
        return BackgroundMotionMode.waves;
      case 'circles':
      default:
        return BackgroundMotionMode.circles;
    }
  }
}

enum ShapeVariant { expressive, rounded, compact }

extension ShapeVariantX on ShapeVariant {
  String get storageValue {
    switch (this) {
      case ShapeVariant.expressive:
        return 'expressive';
      case ShapeVariant.rounded:
        return 'rounded';
      case ShapeVariant.compact:
        return 'compact';
    }
  }

  static ShapeVariant fromStorage(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'expressive':
        return ShapeVariant.expressive;
      case 'compact':
        return ShapeVariant.compact;
      case 'rounded':
      default:
        return ShapeVariant.rounded;
    }
  }

  /// Base corner radius for cards, inputs and buttons.
  double get cornerRadius {
    switch (this) {
      case ShapeVariant.expressive:
        return 24;
      case ShapeVariant.rounded:
        return 14;
      case ShapeVariant.compact:
        return 6;
    }
  }
}

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
  final BackgroundMotionMode backgroundMotionMode;
  final double floatingCirclesSpeed;
  final double floatingCirclesOpacity;
  final ShapeVariant shapeVariant;

  const ThemeSettings({
    this.fontFamily = 'Inter',
    this.primaryColorValue = 0xFF6200EE,
    this.fontWeight = 400,
    this.bubbleRounding = 16.0,
    this.dynamicBubbles = true,
    this.compactMode = false,
    this.navBarHideTimeoutSeconds = 3,
    this.enableParallax = true,
    this.enableFloatingCircles = true,
    this.backgroundMotionMode = BackgroundMotionMode.circles,
    this.floatingCirclesSpeed = 1.0,
    this.floatingCirclesOpacity = 0.5,
    this.shapeVariant = ShapeVariant.rounded,
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
    BackgroundMotionMode? backgroundMotionMode,
    double? floatingCirclesSpeed,
    double? floatingCirclesOpacity,
    ShapeVariant? shapeVariant,
  }) {
    return ThemeSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      fontWeight: fontWeight ?? this.fontWeight,
      bubbleRounding: bubbleRounding ?? this.bubbleRounding,
      dynamicBubbles: dynamicBubbles ?? this.dynamicBubbles,
      compactMode: compactMode ?? this.compactMode,
      navBarHideTimeoutSeconds:
          navBarHideTimeoutSeconds ?? this.navBarHideTimeoutSeconds,
      enableParallax: enableParallax ?? this.enableParallax,
      enableFloatingCircles:
          enableFloatingCircles ?? this.enableFloatingCircles,
      backgroundMotionMode: backgroundMotionMode ?? this.backgroundMotionMode,
      floatingCirclesSpeed: floatingCirclesSpeed ?? this.floatingCirclesSpeed,
      floatingCirclesOpacity:
          floatingCirclesOpacity ?? this.floatingCirclesOpacity,
      shapeVariant: shapeVariant ?? this.shapeVariant,
    );
  }
}

class SettingsService {
  SettingsService._();

  static const _legacyPixelFontFamily = 'PressStart 2P';
  static const _pixelFontFamily = 'Handjet';

  static String normalizeFontFamily(String? rawFontFamily) {
    final normalized = (rawFontFamily ?? '').trim();
    switch (normalized) {
      case '':
        return 'Inter';
      case _legacyPixelFontFamily:
        return _pixelFontFamily;
      case 'Inter':
      case 'Roboto':
      case 'NotoSans':
      case 'OpenSans':
      case 'Oswald':
      case _pixelFontFamily:
      case 'ComicSans MS':
        return normalized;
      default:
        return 'Inter';
    }
  }

  static int normalizeFontWeight(int rawWeight) {
    if (rawWeight >= 100 && rawWeight <= 900) {
      return ((rawWeight / 100).round() * 100).clamp(300, 900);
    }
    if (rawWeight >= 1 && rawWeight <= 9) {
      return (rawWeight * 100).clamp(300, 900);
    }
    return 400;
  }

  static const _fontKey = 'theme_font_family';
  static const _colorKey = 'theme_primary_color';
  static const _weightKey = 'theme_font_weight';
  static const _bubbleRoundingKey = 'ui_bubble_rounding';
  static const _dynamicBubblesKey = 'ui_dynamic_bubbles';
  static const _compactModeKey = 'ui_compact_mode';
  static const _navBarTimeoutKey = 'ui_nav_hide_timeout';
  static const _parallaxKey = 'ui_enable_parallax';
  static const _floatingCirclesKey = 'ui_floating_circles';
  static const _backgroundMotionModeKey = 'ui_background_motion_mode';
  static const _floatingCirclesSpeedKey = 'ui_floating_circles_speed';
  static const _floatingCirclesOpacityKey = 'ui_floating_circles_opacity';
  static const _shapeVariantKey = 'ui_shape_variant';

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
  static const _messageTimestampPrecisionKey =
      'chat_message_timestamp_precision';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _soundEnabledKey = 'notifications_sound_enabled';
  static const _doNotDisturbKey = 'notifications_do_not_disturb';
  static const _notificationTonePathKey = 'notifications_tone_path';
  static const _notificationToneNameKey = 'notifications_tone_name';
  static const _ringtonePathKey = 'notifications_ringtone_path';
  static const _ringtoneNameKey = 'notifications_ringtone_name';
  static const _biometricsKey = 'biometric_enabled';
  static const _foregroundServiceEnabledKey = 'notifications_foreground_service_enabled';
  static const _notificationsMessageEnabledKey = 'notifications_message_enabled';
  static const _notificationsChatEnabledKey = 'notifications_chat_enabled';
  static const _notificationsReactionEnabledKey = 'notifications_reaction_enabled';
  static const _notificationsPostEnabledKey = 'notifications_post_enabled';
  static final Set<String> _coreKeys = <String>{
    _fontKey,
    _colorKey,
    _weightKey,
    _bubbleRoundingKey,
    _dynamicBubblesKey,
    _compactModeKey,
    _navBarTimeoutKey,
    _parallaxKey,
    _floatingCirclesKey,
    _backgroundMotionModeKey,
    _floatingCirclesSpeedKey,
    _floatingCirclesOpacityKey,
    _shapeVariantKey,
    _paleVioletKey,
    _languageKey,
    _textScaleKey,
    _themeModeKey,
  };
  static final Set<String> _deferredKeys = <String>{
    _sessionTimeoutKey,
    _showEmailKey,
    _showPhoneKey,
    _autoDownloadKey,
    _sendByEnterKey,
    _messageTimestampPrecisionKey,
    _notificationsEnabledKey,
    _soundEnabledKey,
    _doNotDisturbKey,
    _notificationTonePathKey,
    _notificationToneNameKey,
    _ringtonePathKey,
    _ringtoneNameKey,
    _biometricsKey,
    _foregroundServiceEnabledKey,
    _notificationsMessageEnabledKey,
    _notificationsChatEnabledKey,
    _notificationsReactionEnabledKey,
    _notificationsPostEnabledKey,
  };
  static Future<void>? _loadSettingsFuture;
  static Future<void>? _loadDeferredSettingsFuture;
  static bool _deferredSettingsLoaded = false;
  static final Set<String> _deferredLocallyModifiedKeys = <String>{};

  // Theme Notifier
  static final ValueNotifier<ThemeSettings> themeNotifier = ValueNotifier(
    const ThemeSettings(),
  );

  // Other Notifiers (restoring missing ones)
  static final ValueNotifier<bool> paleVioletNotifier = ValueNotifier(false);
  static final ValueNotifier<int> sessionTimeoutDaysNotifier = ValueNotifier(
    30,
  );
  static final ValueNotifier<bool> showEmailNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> showPhoneNotifier = ValueNotifier(false);
  static final ValueNotifier<String> languageNotifier = ValueNotifier('en');
  static final ValueNotifier<double> textScaleNotifier = ValueNotifier(1);
  static final ValueNotifier<bool> autoDownloadMediaNotifier = ValueNotifier(
    true,
  );
  static final ValueNotifier<bool> sendByEnterNotifier = ValueNotifier(true);
  static final ValueNotifier<MessageTimestampPrecision>
  messageTimestampPrecisionNotifier = ValueNotifier(
    MessageTimestampPrecision.minutes,
  );
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );
  static final ValueNotifier<bool> biometricsNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> notificationsEnabledNotifier = ValueNotifier(
    true,
  );
  static final ValueNotifier<bool> soundEnabledNotifier = ValueNotifier(true);
  static final ValueNotifier<bool> doNotDisturbNotifier = ValueNotifier(false);
  static final ValueNotifier<String?> notificationTonePathNotifier =
      ValueNotifier(null);
  static final ValueNotifier<String?> notificationToneNameNotifier =
      ValueNotifier(null);
  static final ValueNotifier<String?> ringtonePathNotifier = ValueNotifier(
    null,
  );
  static final ValueNotifier<String?> ringtoneNameNotifier = ValueNotifier(
    null,
  );
  static final ValueNotifier<bool> foregroundServiceEnabledNotifier =
      ValueNotifier(true);
  static final ValueNotifier<bool> notificationsMessageEnabledNotifier =
      ValueNotifier(true);
  static final ValueNotifier<bool> notificationsChatEnabledNotifier =
      ValueNotifier(true);
  static final ValueNotifier<bool> notificationsReactionEnabledNotifier =
      ValueNotifier(false);
  static final ValueNotifier<bool> notificationsPostEnabledNotifier =
      ValueNotifier(true);

  static Future<void> loadSettings() async {
    final inFlight = _loadSettingsFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _loadCoreSettings();
    _loadSettingsFuture = future;
    try {
      await future;
    } finally {
      if (identical(_loadSettingsFuture, future)) {
        _loadSettingsFuture = null;
      }
    }
    unawaited(loadDeferredSettings());
  }

  static Future<void> _loadCoreSettings() async {
    final stored = await SecureStore.readMany(_coreKeys);

    String? valueOf(String key) => stored[key];

    final storedFontFamily = valueOf(_fontKey);
    final normalizedFontFamily = normalizeFontFamily(storedFontFamily);

    themeNotifier.value = ThemeSettings(
      fontFamily: normalizedFontFamily,
      primaryColorValue: int.tryParse(valueOf(_colorKey) ?? '') ?? 0xFF651FFF,
      fontWeight: normalizeFontWeight(
        int.tryParse(valueOf(_weightKey) ?? '') ?? 400,
      ),
      bubbleRounding:
          double.tryParse(valueOf(_bubbleRoundingKey) ?? '') ?? 16.0,
      dynamicBubbles: valueOf(_dynamicBubblesKey) != 'false',
      compactMode: valueOf(_compactModeKey) == 'true',
      navBarHideTimeoutSeconds:
          int.tryParse(valueOf(_navBarTimeoutKey) ?? '') ?? 3,
      enableParallax: valueOf(_parallaxKey) != 'false',
      enableFloatingCircles: valueOf(_floatingCirclesKey) != 'false',
      backgroundMotionMode: BackgroundMotionModeX.fromStorage(
        valueOf(_backgroundMotionModeKey),
      ),
      floatingCirclesSpeed:
          double.tryParse(valueOf(_floatingCirclesSpeedKey) ?? '') ?? 1.0,
      floatingCirclesOpacity:
          double.tryParse(valueOf(_floatingCirclesOpacityKey) ?? '') ?? 0.5,
      shapeVariant: ShapeVariantX.fromStorage(valueOf(_shapeVariantKey)),
    );

    if (storedFontFamily != null && storedFontFamily != normalizedFontFamily) {
      await SecureStore.write(_fontKey, normalizedFontFamily);
    }

    // Load startup-critical settings only. Everything else is hydrated lazily.
    paleVioletNotifier.value = valueOf(_paleVioletKey) == 'true';
    languageNotifier.value = valueOf(_languageKey) ?? 'en';
    textScaleNotifier.value =
        double.tryParse(valueOf(_textScaleKey) ?? '') ?? 1.0;
    themeModeNotifier.value = _themeModeFromString(valueOf(_themeModeKey));
  }

  static Future<void> loadDeferredSettings() async {
    if (_deferredSettingsLoaded) {
      return;
    }
    final inFlight = _loadDeferredSettingsFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = () async {
      final stored = await SecureStore.readMany(_deferredKeys);

      String? valueOf(String key) => stored[key];
      bool canHydrate(String key) => !_deferredLocallyModifiedKeys.contains(key);

      if (canHydrate(_sessionTimeoutKey)) {
        sessionTimeoutDaysNotifier.value =
            int.tryParse(valueOf(_sessionTimeoutKey) ?? '') ?? 30;
      }
      if (canHydrate(_showEmailKey)) {
        showEmailNotifier.value = valueOf(_showEmailKey) == 'true';
      }
      if (canHydrate(_showPhoneKey)) {
        showPhoneNotifier.value = valueOf(_showPhoneKey) == 'true';
      }
      if (canHydrate(_autoDownloadKey)) {
        autoDownloadMediaNotifier.value = valueOf(_autoDownloadKey) != 'false';
      }
      if (canHydrate(_sendByEnterKey)) {
        sendByEnterNotifier.value = valueOf(_sendByEnterKey) != 'false';
      }
      if (canHydrate(_messageTimestampPrecisionKey)) {
        messageTimestampPrecisionNotifier.value =
            MessageTimestampPrecisionX.fromStorage(
              valueOf(_messageTimestampPrecisionKey),
            );
      }

      final bioStr = valueOf(_biometricsKey);
      if (canHydrate(_biometricsKey)) {
        biometricsNotifier.value = bioStr == 'true';
      }
      if (canHydrate(_notificationsEnabledKey)) {
        notificationsEnabledNotifier.value =
            valueOf(_notificationsEnabledKey) != 'false';
      }
      if (canHydrate(_soundEnabledKey)) {
        soundEnabledNotifier.value = valueOf(_soundEnabledKey) != 'false';
      }
      if (canHydrate(_doNotDisturbKey)) {
        doNotDisturbNotifier.value = valueOf(_doNotDisturbKey) == 'true';
      }
      if (canHydrate(_notificationTonePathKey)) {
        notificationTonePathNotifier.value = valueOf(_notificationTonePathKey);
      }
      if (canHydrate(_notificationToneNameKey)) {
        notificationToneNameNotifier.value = valueOf(_notificationToneNameKey);
      }
      if (canHydrate(_ringtonePathKey)) {
        ringtonePathNotifier.value = valueOf(_ringtonePathKey);
      }
      if (canHydrate(_ringtoneNameKey)) {
        ringtoneNameNotifier.value = valueOf(_ringtoneNameKey);
      }
      if (canHydrate(_foregroundServiceEnabledKey)) {
        foregroundServiceEnabledNotifier.value =
            valueOf(_foregroundServiceEnabledKey) != 'false';
      }
      if (canHydrate(_notificationsMessageEnabledKey)) {
        notificationsMessageEnabledNotifier.value =
            valueOf(_notificationsMessageEnabledKey) != 'false';
      }
      if (canHydrate(_notificationsChatEnabledKey)) {
        notificationsChatEnabledNotifier.value =
            valueOf(_notificationsChatEnabledKey) != 'false';
      }
      if (canHydrate(_notificationsReactionEnabledKey)) {
        notificationsReactionEnabledNotifier.value =
            valueOf(_notificationsReactionEnabledKey) == 'true';
      }
      if (canHydrate(_notificationsPostEnabledKey)) {
        notificationsPostEnabledNotifier.value =
            valueOf(_notificationsPostEnabledKey) != 'false';
      }
      _deferredSettingsLoaded = true;
    }();

    _loadDeferredSettingsFuture = future;
    try {
      await future;
    } finally {
      if (identical(_loadDeferredSettingsFuture, future)) {
        _loadDeferredSettingsFuture = null;
      }
    }
  }

  static Future<bool> autoDisableBackgroundEffects() async {
    final current = themeNotifier.value;
    final targetOpacity = current.floatingCirclesOpacity.clamp(0.16, 0.34);
    if (!current.enableParallax &&
        (!current.enableFloatingCircles ||
            current.floatingCirclesOpacity <= targetOpacity)) {
      return false;
    }

    await updateTheme(
      enableParallax: false,
      enableFloatingCircles: true,
      floatingCirclesOpacity: targetOpacity,
    );
    return true;
  }

  static void resetDeferredSettingsCache() {
    _deferredSettingsLoaded = false;
    _loadDeferredSettingsFuture = null;
    _deferredLocallyModifiedKeys.clear();
  }

  static Future<void> refreshAllSettingsFromStorage() async {
    SecureStore.clearMemoryCache();
    _deferredSettingsLoaded = false;
    _loadSettingsFuture = null;
    _loadDeferredSettingsFuture = null;
    _deferredLocallyModifiedKeys.clear();
    await loadSettings();
  }

  static void applyDeferredSettingsDefaults() {
    sessionTimeoutDaysNotifier.value = 30;
    showEmailNotifier.value = false;
    showPhoneNotifier.value = false;
    autoDownloadMediaNotifier.value = true;
    sendByEnterNotifier.value = true;
    messageTimestampPrecisionNotifier.value = MessageTimestampPrecision.minutes;
    biometricsNotifier.value = false;
    notificationsEnabledNotifier.value = true;
    soundEnabledNotifier.value = true;
    doNotDisturbNotifier.value = false;
    notificationTonePathNotifier.value = null;
    notificationToneNameNotifier.value = null;
    ringtonePathNotifier.value = null;
    ringtoneNameNotifier.value = null;
    foregroundServiceEnabledNotifier.value = true;
    notificationsMessageEnabledNotifier.value = true;
    notificationsChatEnabledNotifier.value = true;
    notificationsReactionEnabledNotifier.value = false;
    notificationsPostEnabledNotifier.value = true;
  }

  static Future<void> setBiometricsEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_biometricsKey);
    await SecureStore.write(_biometricsKey, value.toString());
    await SecureStore.write('biometrics_enabled', value.toString());
    biometricsNotifier.value = value;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_notificationsEnabledKey);
    notificationsEnabledNotifier.value = value;
    await SecureStore.write(_notificationsEnabledKey, value.toString());
    if (!value && soundEnabledNotifier.value) {
      await setSoundEnabled(false);
    }
  }

  static Future<void> setSoundEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_soundEnabledKey);
    soundEnabledNotifier.value = value;
    await SecureStore.write(_soundEnabledKey, value.toString());
    if (value && !notificationsEnabledNotifier.value) {
      await setNotificationsEnabled(true);
    }
  }

  static Future<void> setDoNotDisturb(bool value) async {
    _deferredLocallyModifiedKeys.add(_doNotDisturbKey);
    doNotDisturbNotifier.value = value;
    await SecureStore.write(_doNotDisturbKey, value.toString());
  }

  static Future<void> setNotificationTone({
    required String? path,
    required String? displayName,
  }) async {
    _deferredLocallyModifiedKeys
      ..add(_notificationTonePathKey)
      ..add(_notificationToneNameKey);
    notificationTonePathNotifier.value = path;
    notificationToneNameNotifier.value = displayName;
    if (path == null || path.isEmpty) {
      await SecureStore.delete(_notificationTonePathKey);
      await SecureStore.delete(_notificationToneNameKey);
      return;
    }
    await SecureStore.write(_notificationTonePathKey, path);
    if (displayName != null && displayName.isNotEmpty) {
      await SecureStore.write(_notificationToneNameKey, displayName);
    } else {
      await SecureStore.delete(_notificationToneNameKey);
    }
  }

  static Future<void> setRingtone({
    required String? path,
    required String? displayName,
  }) async {
    _deferredLocallyModifiedKeys
      ..add(_ringtonePathKey)
      ..add(_ringtoneNameKey);
    ringtonePathNotifier.value = path;
    ringtoneNameNotifier.value = displayName;
    if (path == null || path.isEmpty) {
      await SecureStore.delete(_ringtonePathKey);
      await SecureStore.delete(_ringtoneNameKey);
      return;
    }
    await SecureStore.write(_ringtonePathKey, path);
    if (displayName != null && displayName.isNotEmpty) {
      await SecureStore.write(_ringtoneNameKey, displayName);
    } else {
      await SecureStore.delete(_ringtoneNameKey);
    }
  }

  static Future<void> setForegroundServiceEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_foregroundServiceEnabledKey);
    foregroundServiceEnabledNotifier.value = value;
    await SecureStore.write(_foregroundServiceEnabledKey, value.toString());
  }

  static Future<void> setNotificationsMessageEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_notificationsMessageEnabledKey);
    notificationsMessageEnabledNotifier.value = value;
    await SecureStore.write(_notificationsMessageEnabledKey, value.toString());
  }

  static Future<void> setNotificationsChatEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_notificationsChatEnabledKey);
    notificationsChatEnabledNotifier.value = value;
    await SecureStore.write(_notificationsChatEnabledKey, value.toString());
  }

  static Future<void> setNotificationsReactionEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_notificationsReactionEnabledKey);
    notificationsReactionEnabledNotifier.value = value;
    await SecureStore.write(_notificationsReactionEnabledKey, value.toString());
  }

  static Future<void> setNotificationsPostEnabled(bool value) async {
    _deferredLocallyModifiedKeys.add(_notificationsPostEnabledKey);
    notificationsPostEnabledNotifier.value = value;
    await SecureStore.write(_notificationsPostEnabledKey, value.toString());
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
    BackgroundMotionMode? backgroundMotionMode,
    double? floatingCirclesSpeed,
    double? floatingCirclesOpacity,
    ShapeVariant? shapeVariant,
  }) async {
    final current = themeNotifier.value;
    final normalizedFontFamily = fontFamily == null
        ? null
        : normalizeFontFamily(fontFamily);
    final normalizedFontWeight = fontWeight == null
        ? null
        : normalizeFontWeight(fontWeight);
    final next = current.copyWith(
      fontFamily: normalizedFontFamily,
      primaryColorValue: primaryColorValue,
      bubbleRounding: bubbleRounding,
      dynamicBubbles: dynamicBubbles,
      compactMode: compactMode,
      navBarHideTimeoutSeconds: navBarHideTimeoutSeconds,
      enableParallax: enableParallax,
      fontWeight: normalizedFontWeight,
      enableFloatingCircles: enableFloatingCircles,
      backgroundMotionMode: backgroundMotionMode,
      floatingCirclesSpeed: floatingCirclesSpeed,
      floatingCirclesOpacity: floatingCirclesOpacity,
      shapeVariant: shapeVariant,
    );

    themeNotifier.value = next;

    if (normalizedFontFamily != null) {
      await SecureStore.write(_fontKey, normalizedFontFamily);
    }
    if (primaryColorValue != null)
      await SecureStore.write(_colorKey, primaryColorValue.toString());
    if (normalizedFontWeight != null)
      await SecureStore.write(_weightKey, normalizedFontWeight.toString());
    if (bubbleRounding != null)
      await SecureStore.write(_bubbleRoundingKey, bubbleRounding.toString());
    if (dynamicBubbles != null)
      await SecureStore.write(_dynamicBubblesKey, dynamicBubbles.toString());
    if (compactMode != null)
      await SecureStore.write(_compactModeKey, compactMode.toString());
    if (navBarHideTimeoutSeconds != null)
      await SecureStore.write(
        _navBarTimeoutKey,
        navBarHideTimeoutSeconds.toString(),
      );
    if (enableParallax != null)
      await SecureStore.write(_parallaxKey, enableParallax.toString());
    if (enableFloatingCircles != null)
      await SecureStore.write(
        _floatingCirclesKey,
        enableFloatingCircles.toString(),
      );
    if (backgroundMotionMode != null)
      await SecureStore.write(
        _backgroundMotionModeKey,
        backgroundMotionMode.storageValue,
      );
    if (floatingCirclesSpeed != null)
      await SecureStore.write(
        _floatingCirclesSpeedKey,
        floatingCirclesSpeed.toString(),
      );
    if (floatingCirclesOpacity != null)
      await SecureStore.write(
        _floatingCirclesOpacityKey,
        floatingCirclesOpacity.toString(),
      );
    if (shapeVariant != null)
      await SecureStore.write(_shapeVariantKey, shapeVariant.storageValue);
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
    _deferredLocallyModifiedKeys.add(_sessionTimeoutKey);
    sessionTimeoutDaysNotifier.value = days;
    await SecureStore.write(_sessionTimeoutKey, days.toString());
  }

  static Future<void> setShowEmail(bool val) async {
    _deferredLocallyModifiedKeys.add(_showEmailKey);
    showEmailNotifier.value = val;
    await SecureStore.write(_showEmailKey, val.toString());
  }

  static Future<void> setShowPhone(bool val) async {
    _deferredLocallyModifiedKeys.add(_showPhoneKey);
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
    _deferredLocallyModifiedKeys.add(_autoDownloadKey);
    autoDownloadMediaNotifier.value = val;
    await SecureStore.write(_autoDownloadKey, val.toString());
  }

  static Future<void> setSendByEnter(bool val) async {
    _deferredLocallyModifiedKeys.add(_sendByEnterKey);
    sendByEnterNotifier.value = val;
    await SecureStore.write(_sendByEnterKey, val.toString());
  }

  static Future<void> setMessageTimestampPrecision(
    MessageTimestampPrecision precision,
  ) async {
    _deferredLocallyModifiedKeys.add(_messageTimestampPrecisionKey);
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
