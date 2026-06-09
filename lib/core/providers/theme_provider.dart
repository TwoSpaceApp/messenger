import 'package:riverpod/riverpod.dart';

class ThemeModeNotifier extends Notifier<String> {
  @override
  String build() => 'system';

  set mode(String v) => state = v;
}

class PrimaryColorNotifier extends Notifier<int> {
  @override
  int build() => 0xFF6200EE;

  set color(int v) => state = v;
}

class PaleVioletThemeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  set enabled(bool v) => state = v;
}

// Theme mode provider (light/dark/system)
final themeModeProvider = NotifierProvider<ThemeModeNotifier, String>(
  ThemeModeNotifier.new,
);

// Primary color provider
final primaryColorProvider = NotifierProvider<PrimaryColorNotifier, int>(
  PrimaryColorNotifier.new,
);

// Pale violet mode provider
final paleVioletThemeProvider = NotifierProvider<PaleVioletThemeNotifier, bool>(
  PaleVioletThemeNotifier.new,
);
