import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';
import 'package:two_space_app/core/services/sentry_service.dart';

/// Performance monitoring utility for tracking operation durations
class PerformanceMonitor {
  PerformanceMonitor(this.operationName) : _stopwatch = Stopwatch()..start();
  final String operationName;
  final Stopwatch _stopwatch;
  bool _isStopped = false;

  /// Stop the timer and record the duration
  Duration stop() {
    if (_isStopped) {
      if (kDebugMode) {
        print(
            'Warning: PerformanceMonitor for "$operationName" was already stopped.');
      }
      return Duration.zero;
    }
    _stopwatch.stop();
    _isStopped = true;

    final duration = _stopwatch.elapsed;

    if (kDebugMode) {
      print('PERF: $operationName took ${duration.inMilliseconds}ms');
    }

    // You can add logic here to report long operations to a monitoring service
    // For example, if duration > 500ms, send to Sentry or another service.

    return duration;
  }

  /// Execute a block of code and monitor its performance
  static Future<T> track<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final monitor = PerformanceMonitor(operationName);
    try {
      return await operation();
    } finally {
      monitor.stop();
    }
  }
}

/// Represents a single performance metric
class PerformanceMetric {
  PerformanceMetric({
    required this.operationName,
    required this.duration,
  }) : timestamp = DateTime.now();
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
}

/// Centralized performance tracking service
class PerformanceService {
  static final List<PerformanceMetric> _metrics = [];
  static const int _maxMetrics = 100; // Store last 100 metrics

  /// Record a new performance metric
  static void record(String operationName, Duration duration) {
    final metric = PerformanceMetric(
      operationName: operationName,
      duration: duration,
    );

    if (_metrics.length >= _maxMetrics) {
      _metrics.removeAt(0);
    }
    _metrics.add(metric);

    if (kDebugMode) {
      print(
          'PERF_METRIC: ${metric.operationName} - ${metric.duration.inMilliseconds}ms');
    }
  }

  /// Get all recorded metrics
  static List<PerformanceMetric> get metrics => List.unmodifiable(_metrics);

  /// Clear all recorded metrics
  static void clear() {
    _metrics.clear();
  }

  /// Report a slow operation to Sentry
  static void reportSlowOperation({
    required PerformanceMetric metric,
    required Duration threshold,
  }) {
    if (kReleaseMode) {
      SentryService.captureMessage(
        'Slow operation: ${metric.operationName}',
        level: SentryLevel.warning,
        extra: {
          'duration_ms': metric.duration.inMilliseconds,
          'threshold_ms': threshold.inMilliseconds,
        },
      );
    }
  }
}
