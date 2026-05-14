import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';

void main() {
  group("UserFacingError", () {
    test("format returns original error when no l10n provided", () {
      final error = Exception("Test error message");
      final result = UserFacingError.format(error);
      expect(result, "Test error message");
    });

    // test("format handles SocketException properly", () {
    //   final error = io.SocketException("Connection failed");
    //   final result = UserFacingError.format(error);
    //   expect(result, "Connection failed");
    // });

    test("format handles TimeoutException properly", () {
      final error = TimeoutException("Request timed out", const Duration(seconds: 30));
      final result = UserFacingError.format(error);
      expect(result, "Request timed out");
    });

    test("format handles specific auth errors", () {
      final error = Exception("auth.register.verify_email_before_login");
      final result = UserFacingError.format(error);
      expect(result, "auth.register.verify_email_before_login");
    });

    test("format handles specific auth profile update error", () {
      final error = Exception("auth.profile.update_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.profile.update_failed");
    });

    test("format handles specific auth avatar update error", () {
      final error = Exception("auth.avatar.update_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.avatar.update_failed");
    });

    test("format handles specific auth login error", () {
      final error = Exception("auth.login.app_credentials_rejected");
      final result = UserFacingError.format(error);
      expect(result, "auth.login.app_credentials_rejected");
    });

    test("format handles specific auth session error", () {
      final error = Exception("auth.login.session_token_missing");
      final result = UserFacingError.format(error);
      expect(result, "auth.login.session_token_missing");
    });

    test("format handles specific auth totp setup error", () {
      final error = Exception("auth.totp.setup_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.totp.setup_failed");
    });

    test("format handles specific auth totp disable error", () {
      final error = Exception("auth.totp.disable_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.totp.disable_failed");
    });

    test("format handles specific auth totp verify error", () {
      final error = Exception("auth.totp.verify_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.totp.verify_failed");
    });

    test("format handles specific auth sessions list error", () {
      final error = Exception("auth.sessions.list_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.sessions.list_failed");
    });

    test("format handles specific auth sessions revoke error", () {
      final error = Exception("auth.sessions.revoke_failed");
      final result = UserFacingError.format(error);
      expect(result, "auth.sessions.revoke_failed");
    });

    test("format handles specific auth register not logged in error", () {
      final error = Exception("auth.register.not_logged_in");
      final result = UserFacingError.format(error);
      expect(result, "auth.register.not_logged_in");
    });

    test("format handles specific auth not authenticated error", () {
      final error = Exception("auth.not_authenticated");
      final result = UserFacingError.format(error);
      expect(result, "auth.not_authenticated");
    });

    test("format handles auto login error prefix", () {
      final error = Exception("auth.register.auto_login_failed::test_detail");
      final result = UserFacingError.format(error);
      expect(result, "auth.register.auto_login_failed::test_detail");
    });

    test("format removes exception prefix from error message", () {
      final error = Exception("TestException: Some error message");
      final result = UserFacingError.format(error);
      expect(result, "Some error message");
    });

    test("format removes exception prefix from error message with spaces", () {
      final error = Exception("  TestException:   Some error message   ");
      final result = UserFacingError.format(error);
      expect(result, "Some error message");
    });

    test("format handles empty error message", () {
      final error = Exception("");
      final result = UserFacingError.format(error);
      expect(result, "");
    });

    test("format handles null error", () {
      final result = UserFacingError.format("null");
      expect(result, "null");
    });

    test("format handles error with no prefix", () {
      final error = Exception("Simple error message");
      final result = UserFacingError.format(error);
      expect(result, "Simple error message");
    });

    test("format handles error with multiple colons", () {
      final error = Exception("TestException: Error: with: multiple: colons");
      final result = UserFacingError.format(error);
      expect(result, "Error: with: multiple: colons");
    });
  });
}