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
  VideoPlayerController? _controller;
  bool _initialized = false;
  String? _error;
  bool _isBuffering = false;
  bool _openedExternally = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        final target = widget.localPath ?? widget.networkUrl;
        if (target == null || target.trim().isEmpty) {
          throw Exception('Video path is empty');
        }

        final opened = await _openInSystemPlayer(target);
        if (!mounted) return;

        if (opened) {
          setState(() {
            _openedExternally = true;
            _error = null;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          });
          return;
        }

        throw Exception('Unable to open system video player');
      }

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
      if (mounted) {
        setState(() {
          _initialized = true;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initialized = false;
        });
      }
    }
  }

  Future<bool> _openInSystemPlayer(String target) async {
    try {
      ProcessResult result;
      if (Platform.isLinux) {
        result = await Process.run('xdg-open', [target]);
      } else if (Platform.isMacOS) {
        result = await Process.run('open', [target]);
      } else if (Platform.isWindows) {
        result = await Process.run('cmd', ['/c', 'start', '', target], runInShell: true);
      } else {
        return false;
      }
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  void _onPlayerChanged() {
    final controller = _controller;
    if (controller == null) return;
    if (!mounted) return;
    final isBuffering = controller.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() => _isBuffering = isBuffering);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerChanged);
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.videoLabel),
        actions: [
          if (_initialized)
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                final controller = _controller;
                if (controller == null) return;
                controller.seekTo(Duration.zero);
                controller.play();
              },
            ),
        ],
      ),
      body: Center(
        child: _error != null
            ? Text(l10n.videoLoadError(_error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error))
            : _openedExternally
                ? const SizedBox.shrink()
            : Stack(
                alignment: Alignment.center,
                children: [
                  if (_initialized)
                    AspectRatio(
                      aspectRatio: _controller?.value.aspectRatio ?? (16 / 9),
                      child: VideoPlayer(_controller!),
                    ),
                  if (!_initialized || _isBuffering)
                    const CircularProgressIndicator(),
                  if (_initialized && !_isBuffering)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          final controller = _controller;
                          if (controller == null) return;
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                      child: ColoredBox(
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            (_controller?.value.isPlaying ?? false)
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 64,
                            color: Colors.white.withAlpha((0.7 * 255).round()),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
      bottomNavigationBar: _initialized
          ? Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      (_controller?.value.isPlaying ?? false)
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      setState(() {
                        final controller = _controller;
                        if (controller == null) return;
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
