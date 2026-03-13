import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class BackgroundEffectsPerformanceService {
  BackgroundEffectsPerformanceService._();

  static final ValueNotifier<bool> noticeVisible = ValueNotifier(false);

  static const int _sampleWindow = 24;
  static const int _slowFrameThresholdMs = 24;
  static const int _slowFrameLimit = 12;

  static bool _started = false;
  static bool _autoDisabledThisSession = false;
  static int _sampledFrames = 0;
  static int _slowFrames = 0;

  static void start() {
    if (_started) {
      return;
    }
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_handleFrameTimings);
  }

  static Future<void> _handleFrameTimings(List<FrameTiming> timings) async {
    if (_autoDisabledThisSession) {
      return;
    }

    final settings = SettingsService.themeNotifier.value;
    if (!settings.enableFloatingCircles) {
      _resetWindow();
      return;
    }

    for (final timing in timings) {
      _sampledFrames += 1;
      final totalFrameMs = timing.totalSpan.inMilliseconds;
      final rasterMs = timing.rasterDuration.inMilliseconds;
      final buildMs = timing.buildDuration.inMilliseconds;
      if (totalFrameMs >= _slowFrameThresholdMs ||
          rasterMs >= _slowFrameThresholdMs ||
          buildMs >= _slowFrameThresholdMs) {
        _slowFrames += 1;
      }
    }

    if (_sampledFrames < _sampleWindow) {
      return;
    }

    final shouldDisable = _slowFrames >= _slowFrameLimit;
    _resetWindow();
    if (!shouldDisable) {
      return;
    }

    final disabled = await SettingsService.autoDisableBackgroundEffects();
    if (!disabled) {
      return;
    }
    _autoDisabledThisSession = true;
    noticeVisible.value = true;
  }

  static void dismissNotice() {
    noticeVisible.value = false;
  }

  static void _resetWindow() {
    _sampledFrames = 0;
    _slowFrames = 0;
  }
}
