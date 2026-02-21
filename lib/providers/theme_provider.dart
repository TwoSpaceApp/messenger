import 'package:riverpod/riverpod.dart';

class ThemeModeNotifier extends Notifier<String> {
  @override
  String build() => 'system';

  void setMode(String v) => state = v;
}

class PrimaryColorNotifier extends Notifier<int> {
  @override
  int build() => 0xFF6200EE;

  void setColor(int v) => state = v;
}

class PaleVioletThemeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool v) => state = v;
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
