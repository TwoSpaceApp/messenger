import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/services/initialization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUpAll(() async {
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

  tearDown(store.clear);

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('Initialization Integration Tests', () {
    test('initialize returns valid result with all steps', () async {
      final result = await InitializationService.initialize();

      expect(result, isNotNull);
      expect(result.steps, isNotEmpty);
      expect(result.totalDuration, isNotNull);
      expect(result.totalDuration.inMilliseconds, greaterThan(0));
      expect(result.allSuccessful, isTrue);
    });

    test("initialize is idempotent - returns cached result on second call",
        () async {
      final result1 = await InitializationService.initialize();
      final result2 = await InitializationService.initialize();

      expect(identical(result1, result2), isTrue,
          reason: "Should return the same cached instance");
    });

    test("all steps have valid metadata", () async {
      final result = await InitializationService.initialize();

      for (final step in result.steps) {
        expect(step.stepName, isNotEmpty,
            reason: "Step name should not be empty");
        expect(step.duration, isNotNull,
            reason: "Duration should not be null");
        expect(step.duration.inMilliseconds, greaterThanOrEqualTo(0),
            reason: "Duration should be non-negative");
        expect(step.success, isA<bool>(),
            reason: "Success should be a boolean");
        expect(step.critical, isA<bool>(),
            reason: "Critical should be a boolean");
      }
    });

    test("toJson produces serializable data", () async {
      final result = await InitializationService.initialize();
      final json = result.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json["totalDuration"], isA<int>());
      expect(json["hasFailures"], isA<bool>());
      expect(json["steps"], isA<List>());

      final steps = json["steps"] as List;
      for (final step in steps) {
        final stepMap = step as Map<String, dynamic>;
        expect(stepMap["name"], isA<String>());
        expect(stepMap["success"], isA<bool>());
        expect(stepMap["critical"], isA<bool>());
        expect(stepMap["duration"], isA<int>());
        expect(stepMap.containsKey("error"), isTrue);
      }
    });

    test("fails list is empty when all successful", () async {
      final result = await InitializationService.initialize();
      expect(result.failures, isEmpty);
      expect(result.successes, hasLength(greaterThan(0)));
    });

    test("step names are descriptive and non-empty", () async {
      final result = await InitializationService.initialize();
      final names = result.steps.map((s) => s.stepName).toList();

      for (final name in names) {
        expect(name, isNotEmpty);
        expect(name.length, greaterThan(3),
            reason: 'Step name "$name" seems too short to be descriptive');
      }
    });

    test("initialization completes within reasonable time", () async {
      final stopwatch = Stopwatch()..start();
      final result = await InitializationService.initialize();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(30000),
          reason: "Initialization should complete within 30 seconds");
      // The internal totalDuration should be close to the measured wall time
      final diff = (stopwatch.elapsedMilliseconds
              .toDouble() -
          result.totalDuration.inMilliseconds.toDouble())
          .abs();
      expect(diff, lessThan(2000.0),
          reason: "Duration mismatch exceeds 2 seconds");
    });

    test("progress callback receives updates", () async {
      final progressUpdates = <String>{};
       final progressTimestamps = <double>[];
       DateTime? lastProgressTime;

       await InitializationService.initialize(
         onProgress: (stepName, progress) {
           progressUpdates.add(stepName);
           final now = DateTime.now().millisecondsSinceEpoch.toDouble();
           progressTimestamps.add(now);
            if (lastProgressTime != null) {
              expect(now, greaterThan(lastProgressTime!.millisecondsSinceEpoch.toDouble()),
                  reason: "Progress timestamps should be increasing");
            }
            lastProgressTime = DateTime.fromMillisecondsSinceEpoch(now.toInt());

           expect(progress, greaterThanOrEqualTo(0.0));
           expect(progress, lessThanOrEqualTo(1.0));
         },
       );

      expect(progressUpdates, isNotEmpty,
          reason: "Progress callback should have been called");
    });

    test("InitializationResult hasFailures is false when all steps pass",
        () async {
      final result = await InitializationService.initialize();
      expect(result.hasFailures, isFalse);
      expect(result.allSuccessful, isTrue);
    });
  });

  group('InitStepResult Integration', () {
    test("InitStepResult created with valid data", () async {
      final result = await InitializationService.initialize();

      for (final step in result.steps) {
        // Verify the computed properties
        expect(step.failed, isFalse);
        expect(step.success, isTrue);
      }
    });
  });
}
