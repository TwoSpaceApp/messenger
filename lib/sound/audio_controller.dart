import 'package:flutter/material.dart';

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

  Future<void> stopAndSave() async {
    final path = await _recorder.stopRecording();
    _state = AudioState.idle;
    //Mетоды на наш сервер реализовать нужно будет или как пока заготовка для Matrix
    notifyListeners();
  }
//Winamp внутри 
}