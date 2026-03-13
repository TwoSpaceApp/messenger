import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class MediaPlayer extends StatefulWidget {
  const MediaPlayer({super.key, this.localPath, this.networkUrl})
      : assert(localPath != null || networkUrl != null,
            'Either localPath or networkUrl must be provided');
  final String? localPath;
  final String? networkUrl;

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  static final Map<String, Duration> _savedPositions = <String, Duration>{};
  static final Map<String, double> _savedVolumes = <String, double>{};

  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _error;
  bool _isBuffering = false;
  bool _controlsVisible = true;
  bool _muted = false;
  BoxFit _videoFit = BoxFit.contain;
  Timer? _hideControlsTimer;
  Timer? _gestureHudTimer;
  Timer? _scrubSeekTimer;
  Duration? _scrubbingPosition;
  Duration _lastPersistedPosition = Duration.zero;
  double _volumeLevel = 1;
  double _lastNonZeroVolume = 1;
  double _brightnessLevel = 0.5;
  bool _gestureHudVisible = false;
  IconData _gestureHudIcon = Icons.volume_up_rounded;
  String _gestureHudLabel = '';
  _GestureZone? _activeGestureZone;
  double _dragStartValue = 0;
  Duration? _pendingScrubTarget;

  static const List<double> _playbackSpeeds = <double>[0.75, 1, 1.25, 1.5, 2];

  String get _mediaKey => widget.localPath ?? widget.networkUrl!;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.networkUrl != null) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.networkUrl!),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        _controller = VideoPlayerController.file(
          File(widget.localPath!),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      _controller?.addListener(_onPlayerChanged);

      await _controller?.initialize();
      await _controller?.setLooping(false);
      await _restorePlaybackState();
      if (mounted) {
        setState(() {
          _initialized = true;
          _error = null;
        });
      }
      _showControlsTemporarily();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initialized = false;
        });
      }
    }
  }

  void _onPlayerChanged() {
    final controller = _controller;
    if (controller == null) return;
    if (!mounted) return;
    final isBuffering = controller.value.isBuffering;
    final isPlaying = controller.value.isPlaying;
    final position = controller.value.position;
    final duration = controller.value.duration;
    final isCompleted = duration > Duration.zero && position >= duration;

    if (isBuffering != _isBuffering || (isCompleted && !_controlsVisible)) {
      setState(() {
        _isBuffering = isBuffering;
        if (isCompleted) {
          _controlsVisible = true;
        }
      });
    }

    if (isPlaying && _controlsVisible) {
      _showControlsTemporarily();
    }

    _persistPlaybackPosition(controller.value.position, controller.value.duration);
  }

  Future<void> _restorePlaybackState() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final savedVolume = _savedVolumes[_mediaKey];
    if (savedVolume != null) {
      _volumeLevel = savedVolume.clamp(0.0, 1.0);
      _muted = _volumeLevel <= 0.001;
      if (_volumeLevel > 0.05) {
        _lastNonZeroVolume = _volumeLevel;
      }
      await controller.setVolume(_muted ? 0 : _volumeLevel);
    }

    final savedPosition = _savedPositions[_mediaKey];
    final duration = controller.value.duration;
    if (savedPosition != null &&
        savedPosition > Duration.zero &&
        duration > const Duration(seconds: 3) &&
        savedPosition < duration - const Duration(seconds: 2)) {
      await controller.seekTo(savedPosition);
      _lastPersistedPosition = savedPosition;
    }
  }

  void _persistPlaybackPosition(Duration position, Duration duration) {
    if (duration <= Duration.zero) {
      return;
    }

    final shouldReset = position >= duration - const Duration(seconds: 1);
    final nextPosition = shouldReset ? Duration.zero : position;
    if (!shouldReset &&
        (nextPosition - _lastPersistedPosition).inSeconds.abs() < 2) {
      return;
    }

    _savedPositions[_mediaKey] = nextPosition;
    _lastPersistedPosition = nextPosition;
  }

  void _showControlsTemporarily() {
    _hideControlsTimer?.cancel();
    if (mounted && !_controlsVisible) {
      setState(() => _controlsVisible = true);
    }

    final controller = _controller;
    if (controller == null || !controller.value.isPlaying) {
      return;
    }

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _controlsVisible = false);
    });
  }

  void _toggleControlsVisibility() {
    final visible = !_controlsVisible;
    setState(() => _controlsVisible = visible);
    if (visible) {
      _showControlsTemporarily();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;
    if (value.isPlaying) {
      await controller.pause();
      _hideControlsTimer?.cancel();
      if (mounted) {
        setState(() => _controlsVisible = true);
      }
      return;
    }

    if (value.duration > Duration.zero && value.position >= value.duration) {
      await controller.seekTo(Duration.zero);
    }
    await controller.play();
    _showControlsTemporarily();
  }

  Future<void> _seekRelative(Duration delta) async {
    final controller = _controller;
    if (controller == null) return;
    final value = controller.value;
    final target = value.position + delta;
    final bounded = target < Duration.zero
        ? Duration.zero
        : (value.duration > Duration.zero && target > value.duration)
            ? value.duration
            : target;
    await controller.seekTo(bounded);
    _showControlsTemporarily();
  }

  Future<void> _toggleMute() async {
    await _setVolumeLevel(_muted ? _lastNonZeroVolume : 0);
    _showControlsTemporarily();
  }

  Future<void> _setVolumeLevel(double nextLevel, {bool showHud = false}) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final clamped = nextLevel.clamp(0.0, 1.0);
    if (clamped > 0.05) {
      _lastNonZeroVolume = clamped;
    }
    _savedVolumes[_mediaKey] = clamped;
    await controller.setVolume(clamped <= 0.001 ? 0 : clamped);
    if (!mounted) {
      return;
    }

    setState(() {
      _volumeLevel = clamped;
      _muted = clamped <= 0.001;
    });
    if (showHud) {
      _showGestureHud(
        clamped <= 0.001
            ? Icons.volume_off_rounded
            : (clamped < 0.5
                ? Icons.volume_down_rounded
                : Icons.volume_up_rounded),
        '${(clamped * 100).round()}%',
      );
    }
  }

  void _setBrightnessLevel(double nextLevel, {bool showHud = false}) {
    final clamped = nextLevel.clamp(0.0, 1.0);
    if (!mounted) {
      return;
    }
    setState(() {
      _brightnessLevel = clamped;
    });
    if (showHud) {
      _showGestureHud(Icons.brightness_6_rounded, '${(clamped * 100).round()}%');
    }
  }

  void _showGestureHud(IconData icon, String label) {
    _gestureHudTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _gestureHudIcon = icon;
      _gestureHudLabel = label;
      _gestureHudVisible = true;
    });
    _gestureHudTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() => _gestureHudVisible = false);
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (!_initialized) {
      return;
    }
    final width = MediaQuery.sizeOf(context).width;
    final dx = details.localPosition.dx;
    final zone = dx <= width * 0.35
        ? _GestureZone.brightness
        : (dx >= width * 0.65 ? _GestureZone.volume : null);
    if (zone == null) {
      _activeGestureZone = null;
      return;
    }

    _activeGestureZone = zone;
    _dragStartValue = zone == _GestureZone.brightness
        ? _brightnessLevel
        : _volumeLevel;
    _showControlsTemporarily();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final zone = _activeGestureZone;
    if (zone == null) {
      return;
    }

    final height = MediaQuery.sizeOf(context).height;
    if (height <= 0) {
      return;
    }

    final deltaFraction = (-details.delta.dy / height) * 2.4;
    final nextValue = (_dragStartValue + deltaFraction).clamp(0.0, 1.0);
    _dragStartValue = nextValue;

    if (zone == _GestureZone.brightness) {
      _setBrightnessLevel(nextValue, showHud: true);
      return;
    }
    unawaited(_setVolumeLevel(nextValue, showHud: true));
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _activeGestureZone = null;
  }

  Future<void> _cyclePlaybackSpeed() async {
    final controller = _controller;
    if (controller == null) return;
    final currentSpeed = controller.value.playbackSpeed;
    final currentIndex = _playbackSpeeds.indexWhere((value) => value == currentSpeed);
    final nextIndex = currentIndex < 0 || currentIndex == _playbackSpeeds.length - 1
        ? 0
        : currentIndex + 1;
    await controller.setPlaybackSpeed(_playbackSpeeds[nextIndex]);
    if (mounted) {
      setState(() {});
    }
    _showControlsTemporarily();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final totalHours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (totalHours > 0) {
      return '${twoDigits(totalHours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _queueScrubSeek(Duration target) {
    _pendingScrubTarget = target;
    if (_scrubSeekTimer != null) {
      return;
    }

    _scrubSeekTimer = Timer(const Duration(milliseconds: 80), () async {
      final nextTarget = _pendingScrubTarget;
      _pendingScrubTarget = null;
      _scrubSeekTimer = null;
      if (nextTarget == null) {
        return;
      }
      final controller = _controller;
      if (controller == null) {
        return;
      }
      await controller.seekTo(nextTarget);
    });
  }

  Widget _buildVideoSurface() {
    final controller = _controller;
    if (controller == null || !_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = controller.value.size;
    return FittedBox(
      fit: _videoFit,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildBrightnessLayer() {
    final delta = _brightnessLevel - 0.5;
    if (delta.abs() < 0.02) {
      return const SizedBox.shrink();
    }

    final color = delta.isNegative ? Colors.black : Colors.white;
    final opacity = (delta.abs() * 0.55).clamp(0.0, 0.28);
    return IgnorePointer(
      child: ColoredBox(color: color.withValues(alpha: opacity)),
    );
  }

  Widget _buildGestureHud() {
    if (!_gestureHudVisible) {
      return const SizedBox.shrink();
    }

    return Align(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_gestureHudIcon, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  _gestureHudLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrubPreview(ThemeData theme, Duration duration) {
    final scrubbingPosition = _scrubbingPosition;
    if (scrubbingPosition == null || duration <= Duration.zero) {
      return const SizedBox.shrink();
    }

    final progress = duration.inMilliseconds == 0
        ? 0.0
        : scrubbingPosition.inMilliseconds / duration.inMilliseconds;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 112,
      child: IgnorePointer(
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(scrubbingPosition),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(ThemeData theme) {
    final controller = _controller;
    if (controller == null || !_initialized) {
      return const SizedBox.shrink();
    }

    final value = controller.value;
    final duration = value.duration;
    final effectivePosition = _scrubbingPosition != null && _scrubbingPosition! <= duration
      ? _scrubbingPosition!
      : (value.position > duration ? duration : value.position);
    final progress = duration.inMilliseconds == 0
        ? 0.0
      : effectivePosition.inMilliseconds / duration.inMilliseconds;

    return IgnorePointer(
      ignoring: !_controlsVisible,
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.58),
                Colors.black.withValues(alpha: 0.18),
                Colors.black.withValues(alpha: 0.64),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: Colors.white,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _videoFit = _videoFit == BoxFit.contain
                                ? BoxFit.cover
                                : BoxFit.contain;
                          });
                          _showControlsTemporarily();
                        },
                        icon: Icon(
                          _videoFit == BoxFit.contain
                              ? Icons.fullscreen
                              : Icons.fullscreen_exit,
                        ),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap: () => _seekRelative(const Duration(seconds: -10)),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _seekRelative(const Duration(seconds: -10)),
                                    icon: const Icon(Icons.replay_10_rounded),
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: _togglePlayback,
                                    icon: Icon(
                                      value.isPlaying
                                          ? Icons.pause_circle_filled_rounded
                                          : Icons.play_circle_fill_rounded,
                                    ),
                                    iconSize: 54,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => _seekRelative(const Duration(seconds: 10)),
                                    icon: const Icon(Icons.forward_10_rounded),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap: () => _seekRelative(const Duration(seconds: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChangeStart: duration == Duration.zero
                                  ? null
                                  : (currentValue) {
                                      setState(() {
                                        _scrubbingPosition = Duration(
                                          milliseconds: (duration.inMilliseconds * currentValue)
                                              .round(),
                                        );
                                      });
                                      _showControlsTemporarily();
                                    },
                              onChanged: duration == Duration.zero
                                  ? null
                                  : (nextValue) {
                                      final target = Duration(
                                        milliseconds: (duration.inMilliseconds * nextValue).round(),
                                      );
                                      setState(() {
                                        _scrubbingPosition = target;
                                      });
                                      _queueScrubSeek(target);
                                      _showControlsTemporarily();
                                    },
                              onChangeEnd: duration == Duration.zero
                                  ? null
                                  : (nextValue) async {
                                      final target = Duration(
                                        milliseconds: (duration.inMilliseconds * nextValue).round(),
                                      );
                                      _scrubSeekTimer?.cancel();
                                      _scrubSeekTimer = null;
                                      _pendingScrubTarget = null;
                                      await controller.seekTo(target);
                                      if (!mounted) {
                                        return;
                                      }
                                      setState(() {
                                        _scrubbingPosition = null;
                                      });
                                      _showControlsTemporarily();
                                    },
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _formatDuration(effectivePosition),
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatDuration(duration),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _cyclePlaybackSpeed,
                                child: Text(
                                  '${controller.value.playbackSpeed.toStringAsFixed(controller.value.playbackSpeed.truncateToDouble() == controller.value.playbackSpeed ? 0 : 2)}x',
                                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleMute,
                                icon: Icon(
                                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                ),
                                color: Colors.white,
                              ),
                              IconButton(
                                onPressed: () async {
                                  await controller.seekTo(Duration.zero);
                                  await controller.play();
                                  _showControlsTemporarily();
                                },
                                icon: const Icon(Icons.replay_rounded),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _gestureHudTimer?.cancel();
    _scrubSeekTimer?.cancel();
    final controller = _controller;
    if (controller != null) {
      _persistPlaybackPosition(controller.value.position, controller.value.duration);
    }
    _controller?.removeListener(_onPlayerChanged);
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _error != null
            ? Text(l10n.videoLoadError(_error!),
                style: TextStyle(color: theme.colorScheme.error))
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleControlsVisibility,
                onVerticalDragStart: _onVerticalDragStart,
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: Colors.black,
                      child: Center(child: _buildVideoSurface()),
                    ),
                    _buildBrightnessLayer(),
                    if (!_initialized || _isBuffering)
                      const Center(child: CircularProgressIndicator()),
                    _buildScrubPreview(
                      theme,
                      _controller?.value.duration ?? Duration.zero,
                    ),
                    _buildGestureHud(),
                    _buildControlsOverlay(theme),
                  ],
                ),
              ),
      ),
    );
  }
}

enum _GestureZone { brightness, volume }
