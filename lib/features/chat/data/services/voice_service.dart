import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

/// Real VoiceService using the 'record' package for audio recording.
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isInitialized = false;
  String? _currentRecordingPath;
  final bool _isSupported = Platform.isAndroid || Platform.isIOS;

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => false; // Playback not implemented here

  /// Initialize the voice service
  Future<void> init() async {
    if (!_isSupported) {
      _isInitialized = false;
      return;
    }
    try {
      _isInitialized = await _recorder.hasPermission();
    } catch (e) {
      _isInitialized = false;
    }
  }

  /// Dispose the recorder
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
      }
      await _recorder.dispose();
    } catch (_) {}
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    if (!_isSupported) return false;
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        _isInitialized = true;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Start recording audio
  Future<String?> startRecording() async {
    if (!_isSupported) return null;

    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return null;

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${dir.path}/voice_$timestamp.m4a';

      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      return _currentRecordingPath;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _recorder.stop();
      _isRecording = false;

      // Verify file exists and has content
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists() && await file.length() > 0) {
          return path;
        }
      }
      return null;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;
        // Delete the file if it exists
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (_) {
      _isRecording = false;
    }
  }

  /// Get recording amplitude (for waveform visualization)
  Future<double?> getAmplitude() async {
    if (!_isRecording) return null;
    try {
      final amp = await _recorder.getAmplitude();
      return amp.current;
    } catch (_) {
      return null;
    }
  }

  /// Play audio (stub - use audioplayers or just_audio for playback)
  Future<void> playAudio(String filePath) async {
    // Playback not implemented in this service
    // Use a separate audio player package like audioplayers
  }
}
