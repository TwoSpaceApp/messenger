import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:two_space_app/services/settings_service.dart';

/// Live parallax background where blobs continuously drift toward phone tilt direction.
class ScreenBackground extends StatefulWidget {
  final Widget child;
  const ScreenBackground({super.key, required this.child});

  @override
  State<ScreenBackground> createState() => _ScreenBackgroundState();
}

class _ScreenBackgroundState extends State<ScreenBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Accelerometer tilt values (direction of gravity)
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  
  // Blob absolute positions (wrapping around screen edges)
  double _blob1X = 0.0;
  double _blob1Y = 0.0;
  double _blob2X = 0.0;
  double _blob2Y = 0.0;
  
  StreamSubscription? _accelSub;
  
  static const double _blob1Size = 350.0;
  static const double _blob2Size = 400.0;

  @override
  void initState() {
    super.initState();
    
    // Animation controller for continuous movement
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateBlobPositions)
      ..repeat();
    
    // Listen to accelerometer for tilt direction
    final settings = SettingsService.themeNotifier.value;
    if (settings.enableParallax && settings.enableFloatingCircles) {
      _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
        if (!mounted) return;
        // X: tilt left/right, Y: tilt forward/backward
        // Normalize to -1..1 range (gravity is ~9.8)
        _tiltX = (event.x / 9.8).clamp(-1.0, 1.0);
        _tiltY = (event.y / 9.8).clamp(-1.0, 1.0);
      });
    }
  }
  
  void _updateBlobPositions() {
    if (!mounted) return;
    
    final settings = SettingsService.themeNotifier.value;
    if (!settings.enableFloatingCircles) return;
    
    final size = MediaQuery.of(context).size;
    final screenW = size.width;
    final screenH = size.height;
    
    // Speed multiplier from settings (default 1.0, now faster with higher base)
    final speedMultiplier = settings.floatingCirclesSpeed * 0.8;
    
    // Move blobs in the direction of tilt
    setState(() {
      _blob1X += _tiltX * speedMultiplier * 2.5;
      _blob1Y += _tiltY * speedMultiplier * 2.5;
      _blob2X += _tiltX * speedMultiplier * 2.0;
      _blob2Y += _tiltY * speedMultiplier * 2.0;
      
      // Wrap around screen edges with some buffer
      final buffer = 100.0;
      
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
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    
    final size = MediaQuery.of(context).size;
    final settings = SettingsService.themeNotifier.value;
    
    // Opacity from settings (now brighter by default - 0.5 -> 0.7)
    final opacity = settings.floatingCirclesOpacity.clamp(0.1, 1.0);
    
    // Initialize blob positions if they are at origin
    if (_blob1X == 0 && _blob1Y == 0) {
      _blob1X = -50;
      _blob1Y = -50;
    }
    if (_blob2X == 0 && _blob2Y == 0) {
      _blob2X = size.width - 80;
      _blob2Y = size.height - 250;
    }

    return Stack(
      children: [
        // Background Color
        Container(color: bgColor),
        
        // Floating circles (if enabled)
        if (settings.enableFloatingCircles) ...[
          // Blob 1 (Primary color) - Brighter
          Positioned(
            left: _blob1X,
            top: _blob1Y,
            width: _blob1Size,
            height: _blob1Size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: isDark ? opacity * 0.7 : opacity * 0.5),
                    primary.withValues(alpha: isDark ? opacity * 0.3 : opacity * 0.2),
                    Colors.transparent
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          // Blob 2 (Secondary color) - Brighter
          Positioned(
            left: _blob2X,
            top: _blob2Y,
            width: _blob2Size,
            height: _blob2Size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: isDark ? opacity * 0.6 : opacity * 0.4),
                    theme.colorScheme.secondary.withValues(alpha: isDark ? opacity * 0.25 : opacity * 0.15),
                    Colors.transparent
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        ],

        // Main Content
        widget.child,
      ],
    );
  }
}
