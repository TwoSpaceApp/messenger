// Enhanced audio player widget with waveform and playback speed
// ignore_for_file: document_ignores

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class EnhancedAudioPlayer extends StatefulWidget {
  const EnhancedAudioPlayer({
    required this.audioUrl,
    super.key,
    this.displayName,
  });
  final String audioUrl;
  final String? displayName;

  @override
  State<EnhancedAudioPlayer> createState() => _EnhancedAudioPlayerState();
}

class _EnhancedAudioPlayerState extends State<EnhancedAudioPlayer> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1;
  final List<double> _speeds = [1.0, 1.25, 1.5, 1.75, 2.0];
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;

  /// Timer-based throttle: update position at most every 100ms.
  Timer? _positionThrottle;
  Duration _pendingPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
      }
    });
    _durationSub = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });
    // Throttle position updates to ~10 Hz to avoid excessive rebuilds.
    _positionSub = _audioPlayer.onPositionChanged.listen((position) {
      _pendingPosition = position;
      if (_positionThrottle == null || !_positionThrottle!.isActive) {
        _positionThrottle = Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _position = _pendingPosition);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _stateSub?.cancel();
    // ignore: discarded_futures
    _durationSub?.cancel();
    // ignore: discarded_futures
    _positionSub?.cancel();
    _positionThrottle?.cancel();
    // ignore: discarded_futures
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
  }

  Future<void> _changeSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    await _audioPlayer.setPlaybackRate(speed);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ShadIconButton.secondary(
                width: 42,
                height: 42,
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    max: _duration.inMilliseconds.toDouble(),
                    value: _position.inMilliseconds.toDouble().clamp(
                      0,
                      _duration.inMilliseconds.toDouble(),
                    ),
                    onChanged: (value) async {
                      await _audioPlayer.seek(
                        Duration(milliseconds: value.toInt()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_position),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(l10n.speedLabel, style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                for (final speed in _speeds)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _playbackSpeed == speed
                        ? ShadButton.secondary(
                            onPressed: () {},
                            height: 32,
                            child: Text('${speed}x'),
                          )
                        : ShadButton.outline(
                            onPressed: () => _changeSpeed(speed),
                            height: 32,
                            child: Text('${speed}x'),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
