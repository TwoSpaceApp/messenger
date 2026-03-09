import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

void main() {
  group('ThemeSettings', () {
    test('copyWith overrides only provided values', () {
      const original = ThemeSettings(
        primaryColorValue: 0xFF000000,
        bubbleRounding: 12,
      );

      final updated = original.copyWith(
        fontFamily: 'Roboto',
        bubbleRounding: 24,
      );

      expect(updated.fontFamily, 'Roboto');
      expect(updated.bubbleRounding, 24);
      expect(updated.primaryColorValue, original.primaryColorValue);
      expect(updated.dynamicBubbles, isTrue);
    });
  });
}
