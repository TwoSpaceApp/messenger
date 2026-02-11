import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/services/watch_service.dart'; // Import WatchService
import 'package:uuid/uuid.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers

enum CallState {
  none,
  outgoing,
  incoming,
  connected,
}

class CallStateData {
  final CallState callState;
  final String? roomId;
  final String? callId;
  final String? remoteUserId;
  final String? remoteUserName;
  final String? remoteUserAvatar;
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final bool isScreenSharing;

  CallStateData({
    this.callState = CallState.none,
    this.roomId,
    this.callId,
    this.remoteUserId,
    this.remoteUserName,
    this.remoteUserAvatar,
    this.localStream,
    this.remoteStream,
    this.isScreenSharing = false,
  });

  CallStateData copyWith({
    CallState? callState,
    String? roomId,
    String? callId,
    String? remoteUserId,
    String? remoteUserName,
    String? remoteUserAvatar,
    MediaStream? localStream,
    MediaStream? remoteStream,
    bool? isScreenSharing,
  }) {
    return CallStateData(
      callState: callState ?? this.callState,
      roomId: roomId ?? this.roomId,
      callId: callId ?? this.callId,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      remoteUserName: remoteUserName ?? this.remoteUserName,
      remoteUserAvatar: remoteUserAvatar ?? this.remoteUserAvatar,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
    );
  }
}

class CallService extends StateNotifier<CallStateData> {
  final ChatMatrixService _matrixService = ChatMatrixService();
  final WatchService _watchService = WatchService();
  final Uuid _uuid = const Uuid();
  RTCPeerConnection? _peerConnection;
  MediaStream? _audioStream; // To hold the original audio stream
  final AudioPlayer _ringtonePlayer = AudioPlayer();

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  CallService() : super(CallStateData()) {
    _watchService.onAcceptCall = answerCall;
    _watchService.onDeclineCall = hangupCall;
    _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _ringtonePlayer.dispose();
    super.dispose();
  }

  Future<void> startCall(String roomId, String userId, String userName, String? userAvatar) async {
    final callId = _uuid.v4();
    state = state.copyWith(
      callState: CallState.outgoing,
      roomId: roomId,
      callId: callId,
      remoteUserId: userId,
      remoteUserName: userName,
      remoteUserAvatar: userAvatar,
    );

    await _createPeerConnection(withVideo: false);
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _matrixService.sendSdpOffer(roomId, callId, offer.sdp!);
  }

  Future<void> receiveCall(String roomId, String callId, String userId, String userName, String? userAvatar, String sdpOffer) async {
    if (state.callState != CallState.none) {
      _matrixService.sendCallHangup(roomId, callId);
      return;
    }
    state = state.copyWith(
      callState: CallState.incoming,
      roomId: roomId,
      callId: callId,
      remoteUserId: userId,
      remoteUserName: userName,
      remoteUserAvatar: userAvatar,
    );

    _watchService.sendIncomingCallNotification(userName);
    await _ringtonePlayer.play(AssetSource('sounds/ringtone.mp3'));
    await _createPeerConnection(withVideo: true); // Be ready to receive video
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdpOffer, 'offer'));
  }

  Future<void> answerCall() async {
    if (state.callState != CallState.incoming) return;
    await _ringtonePlayer.stop();

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    state = state.copyWith(callState: CallState.connected);
    _matrixService.sendSdpAnswer(state.roomId!, state.callId!, answer.sdp!);
  }

  Future<void> hangupCall() async {
    if (state.callState == CallState.none) return;
    await _ringtonePlayer.stop();

    await _audioStream?.dispose();
    await state.localStream?.dispose();
    await state.remoteStream?.dispose();
    await _peerConnection?.close();
    
    _peerConnection = null;
    _audioStream = null;

    _matrixService.sendCallHangup(state.roomId!, state.callId!);
    _watchService.sendHangupNotification();
    state = CallStateData();
  }

  Future<void> toggleScreenShare(bool enabled) async {
    if (_peerConnection == null) return;

    if (enabled) {
      final screenStream = await navigator.mediaDevices.getDisplayMedia({'video': true});
      final screenTrack = screenStream.getVideoTracks().first;

      // Listen for when the user stops sharing via the browser/OS UI
      screenTrack.onEnded = () => toggleScreenShare(false);

      var sender = _peerConnection!.getSenders().firstWhere((s) => s.track?.kind == 'video', orElse: () => null);
      if (sender != null) {
        await sender.replaceTrack(screenTrack);
      } else {
        await _peerConnection!.addTrack(screenTrack);
      }
      state = state.copyWith(isScreenSharing: true, localStream: screenStream);
    } else {
      final audioStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
      final audioTrack = audioStream.getAudioTracks().first;
      
      var sender = _peerConnection!.getSenders().firstWhere((s) => s.track?.kind == 'video', orElse: () => null);
      if (sender != null) {
        await sender.replaceTrack(null); // Stop sending video
        _peerConnection!.removeTrack(sender); // Clean up the sender
      }
      
      // Restore audio
      var audioSender = _peerConnection!.getSenders().firstWhere((s) => s.track?.kind == 'audio');
      await audioSender.replaceTrack(audioTrack);

      state = state.copyWith(isScreenSharing: false, localStream: audioStream);
    }
  }

  Future<void> _createPeerConnection({required bool withVideo}) async {
    _peerConnection = await createPeerConnection(_iceServers, {});
    
    _audioStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': withVideo});
    state = state.copyWith(localStream: _audioStream);
    _audioStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _audioStream!);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        _matrixService.sendIceCandidate(state.roomId!, state.callId!, candidate.toMap());
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        state = state.copyWith(remoteStream: event.streams[0]);
      }
    };
  }

  void addIceCandidate(Map<String, dynamic> candidateMap) {
    final candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    _peerConnection?.addCandidate(candidate);
  }
}

final callServiceProvider = StateNotifierProvider<CallService, CallStateData>((ref) {
  return CallService();
});
