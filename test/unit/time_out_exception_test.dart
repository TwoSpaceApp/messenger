import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/services/time_out_exception.dart';

void main() {
  group("TimeoutException", () {
    test("toString without duration returns only message", () {
      final exception = TimeoutException("Operation timed out");
      expect(exception.toString(), "TimeoutException: Operation timed out");
    });

    test("toString with duration includes duration", () {
      final exception = TimeoutException("Step timed out", const Duration(seconds: 5));
      expect(
        exception.toString(),
        "TimeoutException: Step timed out (took 0:00:05.000000)",
      );
    });

    test("message is accessible", () {
      const message = "Custom timeout message";
      final exception = TimeoutException(message);
      expect(exception.message, message);
    });

    test("duration is nullable", () {
      final exception = TimeoutException("No duration");
      expect(exception.duration, isNull);
    });

    test("duration is set when provided", () {
      const duration = Duration(minutes: 2);
      final exception = TimeoutException("With duration", duration);
      expect(exception.duration, duration);
    });

    test("implements Exception", () {
      final exception = TimeoutException("test");
      expect(exception, isA<Exception>());
    });
  });
}
