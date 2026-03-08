import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/navigation/app_router.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/settings/presentation/screens/dev_menu_screen.dart';

class DevFab extends StatefulWidget {
  const DevFab({super.key});

  @override
  State<DevFab> createState() => _DevFabState();
}

class _DevFabState extends State<DevFab> with SingleTickerProviderStateMixin {
  Offset _pos = const Offset(16, 120);
  late final DevLogger _logger = DevLogger('DevFab');
  Timer? _idleTimer;
  double _opacity = 1;
  bool _showPerformance = false;
  double _fps = 0;

  // To measure FPS
  int _frameCount = 0;
  DateTime _lastFpsCalculation = DateTime.now();

  @override
  void initState() {
    super.initState();
    _resetIdleTimer();
    SchedulerBinding.instance.addPostFrameCallback(_updateFps);
  }

  void _updateFps(Duration timestamp) {
    if (!mounted) return;
    _frameCount++;
    final now = DateTime.now();
    final diff = now.difference(_lastFpsCalculation).inMilliseconds;
    if (diff >= 1000) {
      if (mounted) {
        setState(() {
          _fps = (_frameCount * 1000) / diff;
          _frameCount = 0;
          _lastFpsCalculation = now;
        });
      }
    }
    SchedulerBinding.instance.addPostFrameCallback(_updateFps);
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (_opacity != 1.0) setState(() => _opacity = 1.0);
    _idleTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _opacity = 0.4);
    });
  }

  void _openDevMenu() {
    _resetIdleTimer();
    _logger.debug('DevFab tapped');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = rootNavigatorKey.currentState;
      if (nav != null && mounted) {
        nav.push(MaterialPageRoute(builder: (_) => const DevMenuScreen()));
      }
    });
  }

  void _snapToEdge() {
    final sz = MediaQuery.of(context).size;
    final leftDist = _pos.dx;
    final rightDist = sz.width - _pos.dx - 56;

    setState(() {
      if (leftDist < rightDist) {
        _pos = Offset(8, _pos.dy);
      } else {
        _pos = Offset(sz.width - 64, _pos.dy);
      }
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(kDebugMode || Environment.enableDevTools))
      return const SizedBox.shrink();

    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: GestureDetector(
        onTap: _openDevMenu,
        onLongPress: () {
          setState(() => _showPerformance = !_showPerformance);
          _resetIdleTimer();
        },
        onPanStart: (_) => _resetIdleTimer(),
        onPanUpdate: (details) {
          _resetIdleTimer();
          final sz = MediaQuery.of(context).size;
          final dx = (_pos.dx + details.delta.dx).clamp(0.0, sz.width - 56.0);
          final dy = (_pos.dy + details.delta.dy).clamp(0.0, sz.height - 56.0);
          setState(() => _pos = Offset(dx, dy));
        },
        onPanEnd: (_) {
          _snapToEdge();
          _resetIdleTimer();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _opacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showPerformance)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      '${_fps.toStringAsFixed(1)} FPS\n${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(1)} MB',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.2),
                    ),
                  ),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    final base = Theme.of(context).colorScheme.primaryContainer;
    return Material(
      color: base,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5),
      ),
      elevation: 8,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: Icon(
            Icons.bug_report_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
      ),
    );
  }
}
