import 'package:flutter/material.dart';
import 'audio_recorder_service.dart';
import 'audio_player_service.dart';
import 'audio_state.dart';

class AudioController extends ChangeNotifier {
  final AudioRecorderService _recorder = AudioRecorderService();
  final AudioPlayerService _player = AudioPlayerService();

  AudioState _state = AudioState.idle;
  AudioState get state => _state;

  Future<void> startVoiceRecord() async {
    _state = AudioState.recording;
    await _recorder.startRecording();
    notifyListeners();
  }

  Future<String?> stopAndSave() async {
    final path = await _recorder.stopRecording();
    _state = AudioState.idle;
    notifyListeners();
    return path;
  }

  Future<void> playAudio(String url) async {
    if (_state == AudioState.playing) {
      await stopAudio();
    }
    _state = AudioState.playing;
    notifyListeners();
    try {
      await _player.play(url);
    } catch (e) {
      _state = AudioState.idle;
      notifyListeners();
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
    _state = AudioState.paused; // or paused
    notifyListeners();
  }

  Future<void> stopAudio() async {
    if (_state == AudioState.recording) {
      await stopAndSave();
    }
    await _player.pause(); // audioplayers doesn't have stop properly implemented in wrappers sometimes, but let's assume specific logic or use pause
    _state = AudioState.idle;
    notifyListeners();
  }
}
