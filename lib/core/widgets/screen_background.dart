import 'dart:async';
import 'package:flutter/material.dart';
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

  // Accelerometer tilt values (direction of gravity)
  double _tiltX = 0;
  double _tiltY = 0;

  // Blob absolute positions (wrapping around screen edges)
  double _blob1X = 0;
  double _blob1Y = 0;
  double _blob2X = 0;
  double _blob2Y = 0;

  Size _lastScreenSize = Size.zero;
  bool _positionsInitialized = false;
  bool _appActive = true;

  StreamSubscription? _accelSub;

  static const double _blob1Size = 350;
  static const double _blob2Size = 400;
  static const Duration _animationTick = Duration(milliseconds: 50);

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
      _accelSub?.cancel();
      _accelSub = null;
      _tiltX = 0;
      _tiltY = 0;
      return;
    }

    _accelSub ??= accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      _tiltX = (event.x / 9.8).clamp(-1.0, 1.0);
      _tiltY = (event.y / 9.8).clamp(-1.0, 1.0);
    });
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

    // Speed multiplier from settings (default 1.0, now faster with higher base)
    final speedMultiplier = settings.floatingCirclesSpeed * 0.8;

    // Move blobs in the direction of tilt using a reduced refresh rate.
    _blob1X += _tiltX * speedMultiplier * 2.5;
    _blob1Y += _tiltY * speedMultiplier * 2.5;
    _blob2X += _tiltX * speedMultiplier * 2.0;
    _blob2Y += _tiltY * speedMultiplier * 2.0;

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

    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SettingsService.themeNotifier.removeListener(_syncMotionState);
    _animationTimer?.cancel();
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: SettingsService.themeNotifier,
      child: RepaintBoundary(child: widget.child),
      builder: (context, settings, child) {
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
              Positioned(
                left: _blob2X,
                top: _blob2Y,
                width: _blob2Size,
                height: _blob2Size,
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
              if (child != null) child,
            ],
        );
      },
    );
  }
}
