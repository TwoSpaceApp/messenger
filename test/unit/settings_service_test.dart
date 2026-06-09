import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/utils/secure_store.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      final arguments = (call.arguments as Map<Object?, Object?>?) ?? const {};
      final key = arguments['key'] as String?;

      switch (call.method) {
        case 'read':
          return key == null ? null : store[key];
        case 'write':
          if (key != null) {
            store[key] = arguments['value'] as String? ?? '';
          }
          return null;
        case 'delete':
          if (key != null) {
            store.remove(key);
          }
          return null;
        case 'deleteAll':
          store.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return key != null && store.containsKey(key);
      }
      return null;
    });
  });

  setUp(() async {
    store.clear();
    await SettingsService.refreshAllSettingsFromStorage();
    await Future<void>.delayed(Duration.zero);
    SecureStore.clearMemoryCache();
    SettingsService.resetDeferredSettingsCache();
  });

  group('SettingsService.loadSettings', () {
    test('loads default values when storage is empty', () async {
      await SettingsService.loadSettings();

      expect(SettingsService.themeNotifier.value.fontFamily, 'Inter');
      expect(SettingsService.themeNotifier.value.primaryColorValue, 0xFF651FFF);
      expect(SettingsService.themeNotifier.value.fontWeight, 400);
      expect(SettingsService.themeNotifier.value.bubbleRounding, 16.0);
      expect(SettingsService.themeNotifier.value.compactMode, false);
      expect(SettingsService.languageNotifier.value, 'en');
      expect(SettingsService.themeModeNotifier.value, ThemeMode.system);
    });

    test('loads stored theme values', () async {
      store['theme_font_family'] = 'Roboto';
      store['theme_primary_color'] = '4278190080';
      store['theme_font_weight'] = '700';
      store['ui_bubble_rounding'] = '8.0';
      store['ui_compact_mode'] = 'true';
      store['app_theme_mode'] = 'dark';
      store['app_language'] = 'ru';

      await SettingsService.loadSettings();

      expect(SettingsService.themeNotifier.value.fontFamily, 'Roboto');
      expect(SettingsService.themeNotifier.value.primaryColorValue, 4278190080);
      expect(SettingsService.themeNotifier.value.fontWeight, 700);
      expect(SettingsService.themeNotifier.value.bubbleRounding, 8.0);
      expect(SettingsService.themeNotifier.value.compactMode, true);
      expect(SettingsService.languageNotifier.value, 'ru');
      expect(SettingsService.themeModeNotifier.value, ThemeMode.dark);
    });

    test('normalizes legacy pixel font family', () async {
      store['theme_font_family'] = 'PressStart 2P';
      await SettingsService.loadSettings();

      expect(SettingsService.themeNotifier.value.fontFamily, 'Handjet');
    });

    test('is idempotent - second call does not override stored values', () async {
      store['theme_font_family'] = 'Roboto';
      await SettingsService.loadSettings();
      expect(SettingsService.themeNotifier.value.fontFamily, 'Roboto');

      store['theme_font_family'] = 'Oswald';
      await SettingsService.loadSettings();
      expect(SettingsService.themeNotifier.value.fontFamily, 'Roboto');
    });
  });

  group('SettingsService.loadDeferredSettings', () {
    test('loads deferred notification settings from storage', () async {
      store['notifications_enabled'] = 'false';
      store['notifications_sound_enabled'] = 'false';
      store['notifications_foreground_service_enabled'] = 'false';

      await SettingsService.loadSettings();
      await Future<void>.delayed(Duration.zero);

      expect(SettingsService.notificationsEnabledNotifier.value, false);
      expect(SettingsService.soundEnabledNotifier.value, false);
      expect(SettingsService.foregroundServiceEnabledNotifier.value, false);
    });

    test('applies defaults when deferred keys missing', () async {
      await SettingsService.loadDeferredSettings();

      expect(SettingsService.notificationsEnabledNotifier.value, true);
      expect(SettingsService.biometricsNotifier.value, false);
      expect(SettingsService.sendByEnterNotifier.value, true);
    });
  });

  group('SettingsService.updateTheme', () {
    test('updates notifier and persists to storage', () async {
      await SettingsService.loadSettings();
      await SettingsService.updateTheme(
        fontFamily: 'OpenSans',
        primaryColorValue: 0xFF000000,
        compactMode: true,
      );

      expect(SettingsService.themeNotifier.value.fontFamily, 'OpenSans');
      expect(SettingsService.themeNotifier.value.primaryColorValue, 0xFF000000);
      expect(SettingsService.themeNotifier.value.compactMode, true);
      expect(store['theme_font_family'], 'OpenSans');
      expect(store['theme_primary_color'], '4278190080');
      expect(store['ui_compact_mode'], 'true');
    });

    test('does not persist unchanged fields', () async {
      await SettingsService.loadSettings();
      await SettingsService.updateTheme(fontFamily: 'Roboto');

      expect(store.containsKey('theme_primary_color'), false);
      expect(store['theme_font_family'], 'Roboto');
    });

    test('normalizes font family on update', () async {
      await SettingsService.updateTheme(fontFamily: 'PressStart 2P');
      expect(SettingsService.themeNotifier.value.fontFamily, 'Handjet');
      expect(store['theme_font_family'], 'Handjet');
    });

    test('normalizes font weight on update', () async {
      await SettingsService.updateTheme(fontWeight: 450);
      expect(SettingsService.themeNotifier.value.fontWeight, 500);
    });
  });

  group('SettingsService.normalizeFontFamily', () {
    test('returns Inter for empty string', () {
      expect(SettingsService.normalizeFontFamily(''), 'Inter');
    });

    test('returns Inter for null', () {
      expect(SettingsService.normalizeFontFamily(null), 'Inter');
    });

    test('returns Inter for unknown family', () {
      expect(SettingsService.normalizeFontFamily('Comic Sans'), 'Inter');
    });

    test('passes through known families', () {
      expect(SettingsService.normalizeFontFamily('Roboto'), 'Roboto');
      expect(SettingsService.normalizeFontFamily('Oswald'), 'Oswald');
      expect(SettingsService.normalizeFontFamily('Inter'), 'Inter');
    });
  });

  group('SettingsService.normalizeFontWeight', () {
    test('clamps to 300-900 range', () {
      expect(SettingsService.normalizeFontWeight(100), 300);
      expect(SettingsService.normalizeFontWeight(900), 900);
    });

    test('rounds to nearest hundred', () {
      expect(SettingsService.normalizeFontWeight(450), 500);
      expect(SettingsService.normalizeFontWeight(349), 300);
    });

    test('handles 1-9 scale', () {
      expect(SettingsService.normalizeFontWeight(3), 300);
      expect(SettingsService.normalizeFontWeight(9), 900);
    });

    test('returns 400 for invalid values', () {
      expect(SettingsService.normalizeFontWeight(0), 400);
      expect(SettingsService.normalizeFontWeight(-100), 400);
    });
  });

  group('SettingsService.autoDisableBackgroundEffects', () {
    test('disables effects when running', () async {
      await SettingsService.loadSettings();
      final result = await SettingsService.autoDisableBackgroundEffects();

      expect(result, true);
      expect(
        SettingsService.themeNotifier.value.enableParallax,
        false,
      );
      expect(
        SettingsService.themeNotifier.value.enableFloatingCircles,
        true,
      );
    });

    test('returns false when already disabled', () async {
      await SettingsService.updateTheme(
        enableParallax: false,
        enableFloatingCircles: false,
        floatingCirclesOpacity: 0.2,
      );
      final result = await SettingsService.autoDisableBackgroundEffects();

      expect(result, false);
    });
  });

  group('SettingsService.applyDeferredSettingsDefaults', () {
    test('resets all deferred settings to defaults', () {
      SettingsService.notificationsEnabledNotifier.value = false;
      SettingsService.biometricsNotifier.value = true;

      SettingsService.applyDeferredSettingsDefaults();

      expect(SettingsService.notificationsEnabledNotifier.value, true);
      expect(SettingsService.biometricsNotifier.value, false);
      expect(SettingsService.sendByEnterNotifier.value, true);
    });
  });
}
