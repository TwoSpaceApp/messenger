import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class VoiceMessageRecorder {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _recordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;

  VoiceMessageRecorder() {
    _init();
  }

  Future<void> _init() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();

    await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  Future<String?> startRecording() async {
    if (_isRecording || _recorder == null) return null;

    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      _recordingPath = path.join(dir.path, fileName);

      await _recorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );

      _isRecording = true;

      _recorderSubscription = _recorder!.onProgress!.listen((e) {
        final duration = e.duration;
      });

      return _recordingPath;
    } catch (e) {
      print('Recording error: $e');
      return null;
    }
  }

  Future<Recording?> stopRecording() async {
    if (!_isRecording || _recorder == null) return null;

    try {
      await _recorder!.stopRecorder();
      _isRecording = false;
      await _recorderSubscription?.cancel();

      if (_recordingPath != null && File(_recordingPath!).existsSync()) {
        final file = File(_recordingPath!);
        final stat = await file.stat();
        final duration = await _getAudioDuration(_recordingPath!);

        return Recording(
          path: _recordingPath!,
          duration: duration,
          size: stat.size,
        );
      }
    } catch (e) {
      print('Stop recording error: $e');
    }
    return null;
  }

  Future<void> playRecording(String filePath) async {
    if (_isPlaying || _player == null) return;

    try {
      _isPlaying = true;
      await _player!.startPlayer(
        fromURI: filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          _isPlaying = false;
        },
      );

      _playerSubscription = _player!.onProgress!.listen((e) {
        final position = e.position;
      });
    } catch (e) {
      print('Playback error: $e');
      _isPlaying = false;
    }
  }

  Future<void> stopPlayback() async {
    if (!_isPlaying || _player == null) return;

    try {
      await _player!.stopPlayer();
      _isPlaying = false;
      await _playerSubscription?.cancel();
    } catch (e) {
      print('Stop playback error: $e');
    }
  }

  Future<int> _getAudioDuration(String filePath) async {
    try {
      final duration = await _player!.getDuration(filePath);
      return duration?.inMilliseconds ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Uint8List?> loadAudioData(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsBytes();
    } catch (e) {
      print('Load audio error: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    await _recorderSubscription?.cancel();
    await _playerSubscription?.cancel();
    await _recorder?.closeRecorder();
    await _player?.closePlayer();
    _recorder = null;
    _player = null;
  }

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _recordingPath;
}

class Recording {
  final String path;
  final int duration;
  final int size;

  Recording({
    required this.path,
    required this.duration,
    required this.size,
  });
}

class VoiceMessagePlayer {
  final FlutterSoundPlayer _player;
  bool _isPlaying = false;
  StreamSubscription? _playerSubscription;

  VoiceMessagePlayer() : _player = FlutterSoundPlayer();

  Future<void> init() async {
    await _player.openPlayer();
  }

  Future<void> play(String filePath, {VoidCallback? onComplete}) async {
    if (_isPlaying) await stop();

    try {
      _isPlaying = true;
      await _player.startPlayer(
        fromURI: filePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          _isPlaying = false;
          onComplete?.call();
        },
      );

      _playerSubscription = _player.onProgress!.listen((e) {
        final position = e.position;
      });
    } catch (e) {
      print('Voice playback error: $e');
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    if (!_isPlaying) return;

    try {
      await _player.stopPlayer();
      _isPlaying = false;
      await _playerSubscription?.cancel();
    } catch (e) {
      print('Stop voice playback error: $e');
    }
  }

  Future<void> dispose() async {
    await _playerSubscription?.cancel();
    await _player.closePlayer();
  }

  bool get isPlaying => _isPlaying;
}

import 'dart:async';
import 'package:flutter/services.dart';

const _formatMap = {
  'mp3': 'audio/mpeg',
  'ogg': 'audio/ogg',
};

class BackgroundAudio {
  //It doesn't work properly yet, so I made it on my own with just_audio.
  final Map<String, Uint8List> _sounds = {};

  Future<dynamic> pickFormatAndPlay<F extends List<String>>(
      String urlPrefix,
      List<String> formats, // Changed from F to List<String> for compatibility with Dart, this isn't JavaScript
      bool loop,
      ) async {
    final format = _pickFormat(formats);
    if (format == null) {
      print("Browser doesn't support any of the formats: $formats");
      // Will probably never happen. If happened, format="" and will fail to load audio. Who cares...
    }

    return _play('$urlPrefix.$format', loop);
  }

  Future<dynamic> _play(String url, bool loop) async {
    if (!_sounds.containsKey(url)) {
      try {
        final response = await NetworkAssetBundle(Uri.parse(url)).load(url);
        final buffer = response.buffer.asUint8List();
    // Flutter can't decode audio buffers natively, like through the Web Audio API.
    // You need to use a library like just_audio or audioplayers.
        _sounds[url] = buffer;
      } catch (e) {
        print('Failed to fetch audio from $url: $e');
        rethrow;
      }
    }

    // In a real implementation, this would return an audio player instance
    return {
      'url': url,
      'loop': loop,
      'buffer': _sounds[url],
    };
  }

  String? _pickFormat(List<String> formats) {
    for (final format in formats) {
      if (_formatMap.containsKey(format)) {
        return format;
      }
    }
    return null;
  }
}