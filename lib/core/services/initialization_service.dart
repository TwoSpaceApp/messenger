import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/config/environment_validator.dart';
import 'package:two_space_app/core/services/notification_service.dart';
import 'package:two_space_app/core/services/time_out_exception.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/firebase_options.dart';

/// Result of an initialization step
class InitStepResult {
  InitStepResult({
    required this.stepName,
    required this.success,
    required this.critical,
    required this.duration,
    this.error,
    this.stackTrace,
  });
  final String stepName;
  final bool success;
  final bool critical;
  final dynamic error;
  final StackTrace? stackTrace;
  final Duration duration;

  bool get failed => !success;
}

/// Overall initialization result
class InitializationResult {
  InitializationResult({
    required this.steps,
    required this.totalDuration,
  });
  final List<InitStepResult> steps;
  final Duration totalDuration;

  bool get hasFailures => steps.any((s) => s.failed);
  bool get allSuccessful => steps.every((s) => s.success);

  List<InitStepResult> get failures => steps.where((s) => s.failed).toList();
  List<InitStepResult> get successes => steps.where((s) => s.success).toList();

  Map<String, dynamic> toJson() {
    return {
      'totalDuration': totalDuration.inMilliseconds,
      'hasFailures': hasFailures,
      'steps': steps
          .map(
            (s) => {
              'name': s.stepName,
              'success': s.success,
              'critical': s.critical,
              'duration': s.duration.inMilliseconds,
              'error': s.error?.toString(),
            },
          )
          .toList(),
    };
  }
}

/// Abstract initialization step
abstract class InitializationStep {
  String get name;
  bool get critical; // If true, failure stops initialization
  Duration get timeout;

  Future<void> execute();
}

/// Service to handle app initialization in a structured way
class InitializationService {
  InitializationService._();

  static InitializationResult? _cachedResult;
  static Future<InitializationResult>? _initializeFuture;
  static Future<void>? _deferredStartupFuture;

  static final List<List<InitializationStep>> _stepPhases = [
    <InitializationStep>[
      _FirebaseStep(),
    ],
    <InitializationStep>[
      _EnvironmentStep(),
    ],
    <InitializationStep>[
      _SettingsStep(),
    ],
  ];

  /// Initialize the app with all required steps
  static Future<InitializationResult> initialize({
    void Function(String stepName, double progress)? onProgress,
  }) async {
    final cachedResult = _cachedResult;
    if (cachedResult != null) {
      return cachedResult;
    }
    final inFlight = _initializeFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _initializeInternal(onProgress: onProgress);
    _initializeFuture = future;
    try {
      final result = await future;
      _cachedResult = result;
      _ensureDeferredStartup();
      return result;
    } finally {
      if (identical(_initializeFuture, future)) {
        _initializeFuture = null;
      }
    }
  }

  static Future<InitializationResult> _initializeInternal({
    void Function(String stepName, double progress)? onProgress,
  }) async {
    final startTime = DateTime.now();
    final results = <InitStepResult>[];
    final totalSteps = _stepPhases.fold<int>(
      0,
      (sum, phase) => sum + phase.length,
    );
    var completedSteps = 0;

    for (final phase in _stepPhases) {
      if (phase.length == 1) {
        final step = phase.first;
        if (onProgress != null) {
          onProgress(step.name, completedSteps / totalSteps);
        }
        final stepResult = await _executeStep(step);
        results.add(stepResult);
        completedSteps += 1;
        if (onProgress != null) {
          onProgress(step.name, completedSteps / totalSteps);
        }
        if (stepResult.failed && step.critical) {
          if (kDebugMode) {
            print(
              '❌ Critical step "${step.name}" failed. Stopping initialization.',
            );
          }
          break;
        }
        continue;
      }

      for (final step in phase) {
        if (onProgress != null) {
          onProgress(step.name, completedSteps / totalSteps);
        }
      }

      final phaseResults = await Future.wait(
        phase.map(_executeStep),
      );

      for (final stepResult in phaseResults) {
        results.add(stepResult);
        completedSteps += 1;
        if (onProgress != null) {
          onProgress(stepResult.stepName, completedSteps / totalSteps);
        }
        if (stepResult.failed) {
          final step = phase.firstWhere(
            (candidate) => candidate.name == stepResult.stepName,
          );
          if (step.critical) {
            if (kDebugMode) {
              print(
                '❌ Critical step "${step.name}" failed. Stopping initialization.',
              );
            }
            final result = InitializationResult(
              steps: results,
              totalDuration: DateTime.now().difference(startTime),
            );
            _logInitializationResult(result);
            return result;
          }
        }
      }
    }

    final totalDuration = DateTime.now().difference(startTime);
    final result = InitializationResult(
      steps: results,
      totalDuration: totalDuration,
    );

    _logInitializationResult(result);
    return result;
  }

  static void _ensureDeferredStartup() {
    if (_deferredStartupFuture != null) {
      return;
    }
    _deferredStartupFuture = () async {
      await Future.wait<InitStepResult>(<Future<InitStepResult>>[
        _executeStep(_EnvironmentValidationStep()),
      ]);
      await SettingsService.loadDeferredSettings();
      // Initialize notification service after main initialization.
      try {
        await NotificationService().initialize();
      } on Object catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'InitializationService',
            context: ErrorDescription('while initializing NotificationService'),
          ),
        );
      }
    }();
  }

  /// Execute a single initialization step with timeout and error handling
  static Future<InitStepResult> _executeStep(InitializationStep step) async {
    final stepStartTime = DateTime.now();

    try {
      if (kDebugMode) {
        print('➡️ Starting: ${step.name}');
      }

      await step.execute().timeout(
        step.timeout,
        onTimeout: () {
          throw TimeoutException(
            'Step timed out after ${step.timeout.inSeconds}s',
          );
        },
      );

      final duration = DateTime.now().difference(stepStartTime);

      if (kDebugMode) {
        print('✅ Completed: ${step.name} (${duration.inMilliseconds}ms)');
      }

      return InitStepResult(
        stepName: step.name,
        success: true,
        critical: step.critical,
        duration: duration,
      );
    } on Object catch (e, stackTrace) {
      final duration = DateTime.now().difference(stepStartTime);

      if (kDebugMode) {
        print('❌ Failed: ${step.name} - $e');
      }

      return InitStepResult(
        stepName: step.name,
        success: false,
        critical: step.critical,
        error: e,
        stackTrace: stackTrace,
        duration: duration,
      );
    }
  }

  /// Log initialization result summary
  static void _logInitializationResult(InitializationResult result) {
    if (!kDebugMode) return;

    print('\n${'=' * 50}');
    print('INITIALIZATION SUMMARY');
    print('=' * 50);
    print('Total Duration: ${result.totalDuration.inMilliseconds}ms');
    print('Successful: ${result.successes.length}/${result.steps.length}');

    if (result.hasFailures) {
      print('\nFailed Steps:');
      for (final failure in result.failures) {
        print('  - ${failure.stepName}: ${failure.error}');
      }
    }

    print('=' * 50 + '\n');
  }
}

// ============================================================================
// Initialization Steps
// ============================================================================

class _EnvironmentStep implements InitializationStep {
  @override
  String get name => 'Environment Loading';

  @override
  bool get critical => false; // App can work without .env

  @override
  Duration get timeout => const Duration(seconds: 5);

  @override
  Future<void> execute() async {
    await Environment.load();
  }
}

class _EnvironmentValidationStep implements InitializationStep {
  @override
  String get name => 'Environment Validation';

  @override
  bool get critical => false;

  @override
  Duration get timeout => const Duration(seconds: 3);

  @override
  Future<void> execute() async {
    final validationResult = await EnvironmentValidator.validateOnStartup();

    if (!validationResult.isValid) {
      final errors = validationResult.errors.join(', ');
      if (kDebugMode) {
        print('⚠️ Environment validation warnings: $errors');
      }
      // Don't throw - just log warnings
    }
  }
}

class _SettingsStep implements InitializationStep {
  @override
  String get name => 'Settings Service';

  @override
  bool get critical => true;

  @override
  Duration get timeout => const Duration(seconds: 15);

  @override
  Future<void> execute() async {
    await SettingsService.loadSettings();
  }
}

class _FirebaseStep implements InitializationStep {
  @override
  String get name => 'Firebase Initialization';

  @override
  bool get critical => false; // App can work without Firebase

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<void> execute() async {
    FirebaseOptions? options;
    try {
      options = DefaultFirebaseOptions.currentPlatform;
    } catch (_) {
      // Firebase is not configured for this platform — non-critical.
      return;
    }
    await Firebase.initializeApp(options: options);
  }
}
