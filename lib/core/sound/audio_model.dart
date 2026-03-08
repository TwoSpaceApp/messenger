enum AudioState { idle, recording, playing, paused, uploading }

class AudioModel {
  final String? id;
  final String? path;
  final Duration duration;
  final List<double> waveform;

  AudioModel({this.id, this.path, this.duration = Duration.zero, this.waveform = const []});
}