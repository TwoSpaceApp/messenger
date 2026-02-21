import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/settings_service.dart';

class ThemeSettingsController extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    void listener() => state = SettingsService.themeNotifier.value;
    SettingsService.themeNotifier.addListener(listener);
    ref.onDispose(() => SettingsService.themeNotifier.removeListener(listener));
    return SettingsService.themeNotifier.value;
  }

  Future<void> updatePrimaryColor(Color color) async {
    await SettingsService.updatePrimaryColor(color.toARGB32());
  }

  Future<void> updateFontFamily(String family) async {
    await SettingsService.updateFontFamily(family);
  }

  Future<void> updateFontWeight(int weight) async {
    await SettingsService.updateFontWeight(weight);
  }
}

class PaleVioletSettingsController extends Notifier<bool> {
  @override
  bool build() {
    void listener() => state = SettingsService.paleVioletNotifier.value;
    SettingsService.paleVioletNotifier.addListener(listener);
    ref.onDispose(() => SettingsService.paleVioletNotifier.removeListener(listener));
    return SettingsService.paleVioletNotifier.value;
  }

  Future<void> toggle() async {
    await SettingsService.togglePaleViolet();
  }
}

/// Provider for theme settings
final themeSettingsProvider =
    NotifierProvider<ThemeSettingsController, ThemeSettings>(
  ThemeSettingsController.new,
);

/// Provider for pale violet mode (settings-backed)
final paleVioletSettingsProvider =
    NotifierProvider<PaleVioletSettingsController, bool>(
  PaleVioletSettingsController.new,
);
