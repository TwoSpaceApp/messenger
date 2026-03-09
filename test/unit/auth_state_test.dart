import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';

void main() {
  group('AuthState', () {
    test('authenticated exposes convenience getters', () {
      const state = AuthState.authenticated(userId: '7', token: 'token-1');

      expect(state.isAuthenticated, isTrue);
      expect(state.userId, '7');
      expect(state.token, 'token-1');
    });

    test('unauthenticated hides convenience getters', () {
      const state = AuthState.unauthenticated();

      expect(state.isAuthenticated, isFalse);
      expect(state.userId, isNull);
      expect(state.token, isNull);
    });

    test('error hides convenience getters', () {
      const state = AuthState.error(message: 'boom');

      expect(state.isAuthenticated, isFalse);
      expect(state.userId, isNull);
      expect(state.token, isNull);
    });
  });
}
