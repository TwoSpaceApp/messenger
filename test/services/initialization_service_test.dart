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

  group("InitializationService", () {
    test("initialize completes without crashing", () async {
      final result = await InitializationService.initialize();
      expect(result, isNotNull);
      expect(result.steps, isNotEmpty);
    });

    test("initialization result contains step information", () async {
      final result = await InitializationService.initialize();
      expect(result.totalDuration, isNotNull);
      expect(result.steps.length, greaterThan(0));

      for (final step in result.steps) {
        expect(step.stepName, isNotEmpty);
        expect(step.duration, isNotNull);
      }
    });

    test("toJson produces valid structure", () async {
      final result = await InitializationService.initialize();
      final json = result.toJson();

      expect(json["totalDuration"], isNotNull);
      expect(json["hasFailures"], isA<bool>());
      expect(json["steps"], isA<List>());
    });
  });
}
