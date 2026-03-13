import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

/// Live parallax background where blobs continuously drift toward phone tilt direction.
class ScreenBackground extends StatefulWidget {
  const ScreenBackground({required this.child, super.key});
  final Widget child;

  @override
  State<ScreenBackground> createState() => _ScreenBackgroundState();
}

class _ScreenBackgroundState extends State<ScreenBackground>
    with WidgetsBindingObserver {
  Timer? _animationTimer;
  final ValueNotifier<int> _paintTick = ValueNotifier<int>(0);

  // Accelerometer tilt values (direction of gravity)
  double _tiltX = 0;
  double _tiltY = 0;
  double _smoothedTiltX = 0;
  double _smoothedTiltY = 0;

  // Blob absolute positions (wrapping around screen edges)
  double _blob1X = 0;
  double _blob1Y = 0;
  double _blob2X = 0;
  double _blob2Y = 0;

  Size _lastScreenSize = Size.zero;
  bool _positionsInitialized = false;
  bool _appActive = true;

  StreamSubscription? _accelSub;
  bool _accelerometerUnavailable = false;
  DateTime? _lastAnimationAt;

  static const double _blob1Size = 350;
  static const double _blob2Size = 400;
  static const Duration _animationTick = Duration(milliseconds: 33);
  static const double _minVisualDelta = 0.12;
  static const double _tiltSmoothing = 0.18;

  void _syncMotionState() {
    final settings = SettingsService.themeNotifier.value;
    final shouldAnimate = settings.enableFloatingCircles && _appActive;

    if (shouldAnimate) {
      _animationTimer ??= Timer.periodic(_animationTick, (_) {
        if (!mounted) return;
        _updateBlobPositions();
      });
    } else {
      _animationTimer?.cancel();
      _animationTimer = null;
    }

    final shouldListenToAccel =
        settings.enableParallax && settings.enableFloatingCircles && _appActive;
    if (!shouldListenToAccel) {
      _cancelAccelSub();
      _accelSub = null;
      _tiltX = 0;
      _tiltY = 0;
      return;
    }

    if (_accelerometerUnavailable) {
      _tiltX = 0;
      _tiltY = 0;
      _smoothedTiltX = 0;
      _smoothedTiltY = 0;
      return;
    }

    try {
      _accelSub ??= accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          if (!mounted) return;
          _tiltX = (event.x / 9.8).clamp(-1.0, 1.0);
          _tiltY = (event.y / 9.8).clamp(-1.0, 1.0);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (_isMissingPluginError(error)) {
            _accelerometerUnavailable = true;
          }
          _tiltX = 0;
          _tiltY = 0;
          _smoothedTiltX = 0;
          _smoothedTiltY = 0;
          _cancelAccelSub();
          _accelSub = null;
        },
        cancelOnError: true,
      );
    } catch (error) {
      if (_isMissingPluginError(error)) {
        _accelerometerUnavailable = true;
      }
      _tiltX = 0;
      _tiltY = 0;
      _smoothedTiltX = 0;
      _smoothedTiltY = 0;
      _cancelAccelSub();
      _accelSub = null;
    }
  }

  bool _isMissingPluginError(Object error) {
    if (error is MissingPluginException) return true;
    return error.toString().contains('MissingPluginException');
  }

  void _cancelAccelSub() {
    final sub = _accelSub;
    if (sub == null) return;
    unawaited(sub.cancel().catchError((_) {}));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SettingsService.themeNotifier.addListener(_syncMotionState);
    _syncMotionState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    _syncMotionState();
  }

  void _updateBlobPositions() {
    if (!mounted) return;

    final settings = SettingsService.themeNotifier.value;
    if (!settings.enableFloatingCircles) return;

    final size = _lastScreenSize;
    if (size == Size.zero) return;
    final screenW = size.width;
    final screenH = size.height;
    final now = DateTime.now();
    final elapsedMs = _lastAnimationAt == null
      ? _animationTick.inMilliseconds.toDouble()
      : now.difference(_lastAnimationAt!).inMicroseconds / 1000;
    _lastAnimationAt = now;
    final deltaFactor = (elapsedMs / 16.0).clamp(0.6, 2.6);

    // Speed multiplier from settings (default 1.0, now faster with higher base)
    final speedMultiplier = settings.floatingCirclesSpeed * 0.8;
    _smoothedTiltX += (_tiltX - _smoothedTiltX) * _tiltSmoothing;
    _smoothedTiltY += (_tiltY - _smoothedTiltY) * _tiltSmoothing;

    // Move blobs in the direction of tilt using a reduced refresh rate.
    final nextBlob1X = _blob1X + _smoothedTiltX * speedMultiplier * 1.35 * deltaFactor;
    final nextBlob1Y = _blob1Y + _smoothedTiltY * speedMultiplier * 1.35 * deltaFactor;
    final nextBlob2X = _blob2X + _smoothedTiltX * speedMultiplier * 1.05 * deltaFactor;
    final nextBlob2Y = _blob2Y + _smoothedTiltY * speedMultiplier * 1.05 * deltaFactor;

    final changedEnough =
        (nextBlob1X - _blob1X).abs() >= _minVisualDelta ||
        (nextBlob1Y - _blob1Y).abs() >= _minVisualDelta ||
        (nextBlob2X - _blob2X).abs() >= _minVisualDelta ||
        (nextBlob2Y - _blob2Y).abs() >= _minVisualDelta;

    if (!changedEnough) {
      return;
    }

    _blob1X = nextBlob1X;
    _blob1Y = nextBlob1Y;
    _blob2X = nextBlob2X;
    _blob2Y = nextBlob2Y;

    // Wrap around screen edges with some buffer
    const buffer = 100.0;

    // Blob 1 wrapping
    if (_blob1X < -_blob1Size - buffer) _blob1X = screenW + buffer;
    if (_blob1X > screenW + buffer) _blob1X = -_blob1Size - buffer;
    if (_blob1Y < -_blob1Size - buffer) _blob1Y = screenH + buffer;
    if (_blob1Y > screenH + buffer) _blob1Y = -_blob1Size - buffer;

    // Blob 2 wrapping
    if (_blob2X < -_blob2Size - buffer) _blob2X = screenW + buffer;
    if (_blob2X > screenW + buffer) _blob2X = -_blob2Size - buffer;
    if (_blob2Y < -_blob2Size - buffer) _blob2Y = screenH + buffer;
    if (_blob2Y > screenH + buffer) _blob2Y = -_blob2Size - buffer;

    _paintTick.value += 1;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SettingsService.themeNotifier.removeListener(_syncMotionState);
    _animationTimer?.cancel();
    unawaited(_accelSub?.cancel().catchError((_) {}));
    _accelSub = null;
    _paintTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        SettingsService.themeNotifier,
        _paintTick,
      ]),
      child: RepaintBoundary(child: widget.child),
      builder: (context, child) {
        final settings = SettingsService.themeNotifier.value;
        final size = MediaQuery.sizeOf(context);
        _lastScreenSize = size;

        if (!_positionsInitialized) {
          // Initial blob positions depend on the screen size; set once.
          _blob1X = -50;
          _blob1Y = -50;
          _blob2X = size.width - 80;
          _blob2Y = size.height - 250;
          _positionsInitialized = true;
        }

        // Opacity from settings
        final opacity = settings.floatingCirclesOpacity.clamp(0.1, 1.0);

        if (!settings.enableFloatingCircles) {
          return Stack(
            children: [
              ColoredBox(color: bgColor),
              if (child != null) child,
            ],
          );
        }

        return Stack(
          children: [
            ColoredBox(color: bgColor),
            Positioned(
              left: _blob1X,
              top: _blob1Y,
              width: _blob1Size,
              height: _blob1Size,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primary.withValues(
                              alpha: isDark ? opacity * 0.7 : opacity * 0.5),
                          primary.withValues(
                              alpha: isDark ? opacity * 0.3 : opacity * 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _blob2X,
              top: _blob2Y,
              width: _blob2Size,
              height: _blob2Size,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.secondary.withValues(
                              alpha: isDark ? opacity * 0.6 : opacity * 0.4),
                          theme.colorScheme.secondary.withValues(
                              alpha: isDark ? opacity * 0.25 : opacity * 0.15),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (child != null) child,
          ],
        );
      },
    );
  }
}
