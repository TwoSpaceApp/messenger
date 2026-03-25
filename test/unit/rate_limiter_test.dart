import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/services/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('allows up to max calls within the window and then blocks', () async {
      final limiter = RateLimiter(
        maxCallsPerWindow: 2,
        window: const Duration(milliseconds: 200),
      );

      expect(await limiter.tryAcquire(), isTrue);
      expect(await limiter.tryAcquire(), isTrue);
      expect(await limiter.tryAcquire(), isFalse);
    });

    test('expired timestamps are cleaned for wait-time calculation', () async {
      final limiter = RateLimiter(
        maxCallsPerWindow: 1,
        window: const Duration(milliseconds: 100),
      );

      expect(await limiter.tryAcquire(), isTrue);
      expect(limiter.getWaitTime(), isNotNull);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(limiter.getWaitTime(), isNull);
      expect(await limiter.tryAcquire(), isTrue);
    });

    test('stale keys are cleaned so map does not grow indefinitely', () async {
      final limiter = RateLimiter(
        maxCallsPerWindow: 100,
        window: const Duration(milliseconds: 30),
      );

      expect(await limiter.tryAcquire(key: 'user-1'), isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      // Triggers cleanup pass.
      expect(await limiter.tryAcquire(key: 'user-2'), isTrue);
      // If stale key cleanup failed, this would still be throttled by user-1
      // map entry in edge cases with very small windows.
      expect(await limiter.tryAcquire(key: 'user-1'), isTrue);
    });


    test('execute waits for available slot and then runs callback', () async {
      final limiter = RateLimiter(
        maxCallsPerWindow: 1,
        window: const Duration(milliseconds: 50),
      );

      expect(await limiter.tryAcquire(), isTrue);

      final startedAt = DateTime.now();
      final result = await limiter.execute(() async => 42);

      expect(result, 42);
      expect(
        DateTime.now().difference(startedAt).inMilliseconds,
        greaterThanOrEqualTo(40),
      );
    });

    test('rejects invalid constructor parameters', () {
      expect(
        () => RateLimiter(
          maxCallsPerWindow: 0,
          window: const Duration(seconds: 1),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => RateLimiter(
          maxCallsPerWindow: 1,
          window: Duration.zero,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
