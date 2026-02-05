import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/services/native_throat_service.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();

  bool _isRecording = false;
  bool _isInitialized = false;
  String? _currentRecordingPath;
  final bool _isSupported = Platform.isWindows; // For now, only Windows is supported

  late final NativeThroatService _nativeThroatService;

  VoiceService._internal();

  factory VoiceService() {
    return _instance;
  }

  Future<void> init() async {
    if (!_isSupported) {
      _isInitialized = false;
      return;
    }
    _nativeThroatService = NativeThroatService();
    _isInitialized = true;
  }

  Future<void> dispose() async {
    // Nothing to dispose
  }

  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  Future<bool> requestMicrophonePermission() async {
    // On Windows, we don't need to request permissions in the same way as mobile.
    // We can assume we have permission for now.
    return true;
  }

  Future<String?> startRecording() async {
    if (!_isInitialized) return null;
    
    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return null;

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${dir.path}/voice_$timestamp.wav';

      final result = _nativeThroatService.startRecording(_currentRecordingPath!);
      if (result != 0) {
        return null;
      }

      _isRecording = true;
      return _currentRecordingPath;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

  Future<String?> stopRecording() async {
    if (!_isInitialized || !_isRecording) return null;
    
    try {
      _nativeThroatService.stopRecording();
      _isRecording = false;

      final path = _currentRecordingPath;

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

  Future<void> playAudio(String filePath) async {
    // Playback is not implemented yet.
  }

  bool get isPlaying => false;
}
