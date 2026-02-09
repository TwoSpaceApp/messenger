import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

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

  CallStateData({
    this.callState = CallState.none,
    this.roomId,
    this.callId,
    this.remoteUserId,
    this.remoteUserName,
    this.remoteUserAvatar,
    this.localStream,
    this.remoteStream,
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
    );
  }
}

class CallService extends StateNotifier<CallStateData> {
  final ChatMatrixService _matrixService = ChatMatrixService();
  final Uuid _uuid = const Uuid();
  RTCPeerConnection? _peerConnection;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ]
  };

  CallService() : super(CallStateData());

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

    await _createPeerConnection();
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // This is a simplified version. In a real app, you'd send this via ChatMatrixService
    print("--- SENDING OFFER ---");
    print(offer.sdp);
    // _matrixService.sendSdpOffer(roomId, callId, offer.sdp!);
  }

  Future<void> receiveCall(String roomId, String callId, String userId, String userName, String? userAvatar, String sdpOffer) async {
    if (state.callState != CallState.none) {
      // _matrixService.sendCallHangup(roomId, callId);
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

    await _createPeerConnection();
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(sdpOffer, 'offer'));
  }

  Future<void> answerCall() async {
    if (state.callState != CallState.incoming) return;

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    state = state.copyWith(callState: CallState.connected);

    // This is a simplified version. In a real app, you'd send this via ChatMatrixService
    print("--- SENDING ANSWER ---");
    print(answer.sdp);
    // _matrixService.sendSdpAnswer(state.roomId!, state.callId!, answer.sdp!);
  }

  Future<void> hangupCall() async {
    if (state.callState == CallState.none) return;

    await _peerConnection?.close();
    _peerConnection = null;
    await state.localStream?.dispose();
    await state.remoteStream?.dispose();

    // _matrixService.sendCallHangup(state.roomId!, state.callId!);
    state = CallStateData();
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers, {});

    final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
    state = state.copyWith(localStream: stream);
    stream.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, stream);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        // This is a simplified version. In a real app, you'd send this via ChatMatrixService
        print("--- SENDING ICE CANDIDATE ---");
        print(candidate.candidate);
        // _matrixService.sendIceCandidate(state.roomId!, state.callId!, candidate.toMap());
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.track.kind == 'audio') {
        state = state.copyWith(remoteStream: event.streams[0]);
      }
    };
  }

  // This would be called when an ICE candidate is received from the other user
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
