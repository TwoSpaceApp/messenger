import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

/// Live parallax background where blobs continuously drift toward phone tilt direction.
/// Uses CustomPainter so blob animation never rebuilds the child widget tree.
class ScreenBackground extends StatefulWidget {
  const ScreenBackground({required this.child, super.key});
  final Widget child;

  @override
  State<ScreenBackground> createState() => _ScreenBackgroundState();
}

class _ScreenBackgroundState extends State<ScreenBackground>
    with WidgetsBindingObserver {
  Timer? _animationTimer;
  final _blobNotifier = _BlobPositionNotifier();

  double _tiltX = 0;
  double _tiltY = 0;
  double _smoothedTiltX = 0;
  double _smoothedTiltY = 0;

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

    final speedMultiplier = settings.floatingCirclesSpeed * 0.8;
    _smoothedTiltX += (_tiltX - _smoothedTiltX) * _tiltSmoothing;
    _smoothedTiltY += (_tiltY - _smoothedTiltY) * _tiltSmoothing;

    var b1x = _blobNotifier.blob1X + _smoothedTiltX * speedMultiplier * 1.35 * deltaFactor;
    var b1y = _blobNotifier.blob1Y + _smoothedTiltY * speedMultiplier * 1.35 * deltaFactor;
    var b2x = _blobNotifier.blob2X + _smoothedTiltX * speedMultiplier * 1.05 * deltaFactor;
    var b2y = _blobNotifier.blob2Y + _smoothedTiltY * speedMultiplier * 1.05 * deltaFactor;

    final changedEnough =
        (b1x - _blobNotifier.blob1X).abs() >= _minVisualDelta ||
        (b1y - _blobNotifier.blob1Y).abs() >= _minVisualDelta ||
        (b2x - _blobNotifier.blob2X).abs() >= _minVisualDelta ||
        (b2y - _blobNotifier.blob2Y).abs() >= _minVisualDelta;

    if (!changedEnough) return;

    const buffer = 100.0;
    if (b1x < -_blob1Size - buffer) b1x = screenW + buffer;
    if (b1x > screenW + buffer) b1x = -_blob1Size - buffer;
    if (b1y < -_blob1Size - buffer) b1y = screenH + buffer;
    if (b1y > screenH + buffer) b1y = -_blob1Size - buffer;
    if (b2x < -_blob2Size - buffer) b2x = screenW + buffer;
    if (b2x > screenW + buffer) b2x = -_blob2Size - buffer;
    if (b2y < -_blob2Size - buffer) b2y = screenH + buffer;
    if (b2y > screenH + buffer) b2y = -_blob2Size - buffer;

    _blobNotifier.update(b1x, b1y, b2x, b2y);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SettingsService.themeNotifier.removeListener(_syncMotionState);
    _animationTimer?.cancel();
    unawaited(_accelSub?.cancel().catchError((_) {}));
    _accelSub = null;
    _blobNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.backgroundBlobPrimary(context);
    final secondary = AppColors.backgroundBlobSecondary(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.backgroundGradientStart(context),
          AppColors.backgroundGradientEnd(context),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: SettingsService.themeNotifier,
      child: widget.child,
      builder: (context, child) {
        final settings = SettingsService.themeNotifier.value;
        final size = MediaQuery.sizeOf(context);
        _lastScreenSize = size;

        if (!_positionsInitialized) {
          _blobNotifier.update(-50, -50, size.width - 80, size.height - 250);
          _positionsInitialized = true;
        }

        if (!settings.enableFloatingCircles) {
          return DecoratedBox(
            decoration: backgroundDecoration,
            child: child ?? const SizedBox.shrink(),
          );
        }

        final opacity = settings.floatingCirclesOpacity.clamp(0.1, 1.0);

        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(decoration: backgroundDecoration),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: size,
                    painter: _BlobPainter(
                      repaint: _blobNotifier,
                      primary: primary,
                      secondary: secondary,
                      isDark: isDark,
                      opacity: opacity,
                      blob1Size: _blob1Size,
                      blob2Size: _blob2Size,
                      blobNotifier: _blobNotifier,
                    ),
                  ),
                ),
              ),
            ),
            if (child != null) Positioned.fill(child: child),
          ],
        );
      },
    );
  }
}

class _BlobPositionNotifier extends ChangeNotifier {
  double blob1X = 0;
  double blob1Y = 0;
  double blob2X = 0;
  double blob2Y = 0;

  void update(double b1x, double b1y, double b2x, double b2y) {
    blob1X = b1x;
    blob1Y = b1y;
    blob2X = b2x;
    blob2Y = b2y;
    notifyListeners();
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({
    required Listenable repaint,
    required this.primary,
    required this.secondary,
    required this.isDark,
    required this.opacity,
    required this.blob1Size,
    required this.blob2Size,
    required this.blobNotifier,
  }) : super(repaint: repaint);

  final Color primary;
  final Color secondary;
  final bool isDark;
  final double opacity;
  final double blob1Size;
  final double blob2Size;
  final _BlobPositionNotifier blobNotifier;

  @override
  void paint(Canvas canvas, Size size) {
    final center1 = Offset(
      blobNotifier.blob1X + blob1Size / 2,
      blobNotifier.blob1Y + blob1Size / 2,
    );
    final gradient1 = ui.Gradient.radial(
      center1,
      blob1Size / 2,
      [
        primary.withValues(alpha: isDark ? opacity * 0.62 : opacity * 0.3),
        primary.withValues(alpha: isDark ? opacity * 0.24 : opacity * 0.12),
        Colors.transparent,
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center1,
      blob1Size / 2,
      Paint()..shader = gradient1,
    );

    final center2 = Offset(
      blobNotifier.blob2X + blob2Size / 2,
      blobNotifier.blob2Y + blob2Size / 2,
    );
    final gradient2 = ui.Gradient.radial(
      center2,
      blob2Size / 2,
      [
        secondary.withValues(alpha: isDark ? opacity * 0.54 : opacity * 0.24),
        secondary.withValues(alpha: isDark ? opacity * 0.22 : opacity * 0.1),
        Colors.transparent,
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center2,
      blob2Size / 2,
      Paint()..shader = gradient2,
    );
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) =>
      primary != oldDelegate.primary ||
      secondary != oldDelegate.secondary ||
      isDark != oldDelegate.isDark ||
      opacity != oldDelegate.opacity;
}
