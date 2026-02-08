import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CallState {
  none,
  outgoing,
  incoming,
  connected,
}

class CallStateData {
  final CallState callState;
  final String? roomId;
  final String? remoteUserId;
  final String? remoteUserName;
  final String? remoteUserAvatar;

  CallStateData({
    this.callState = CallState.none,
    this.roomId,
    this.remoteUserId,
    this.remoteUserName,
    this.remoteUserAvatar,
  });

  CallStateData copyWith({
    CallState? callState,
    String? roomId,
    String? remoteUserId,
    String? remoteUserName,
    String? remoteUserAvatar,
  }) {
    return CallStateData(
      callState: callState ?? this.callState,
      roomId: roomId ?? this.roomId,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      remoteUserName: remoteUserName ?? this.remoteUserName,
      remoteUserAvatar: remoteUserAvatar ?? this.remoteUserAvatar,
    );
  }
}

class CallService extends StateNotifier<CallStateData> {
  CallService() : super(CallStateData());

  void startCall(String roomId, String userId, String userName, String? userAvatar) {
    state = CallStateData(
      callState: CallState.outgoing,
      roomId: roomId,
      remoteUserId: userId,
      remoteUserName: userName,
      remoteUserAvatar: userAvatar,
    );
    // Here we would initiate the call via Matrix (e.g., send m.call.invite)
  }

  void receiveCall(String roomId, String userId, String userName, String? userAvatar) {
    if (state.callState != CallState.none) {
      // Already in a call, reject the new one automatically
      // Here we would send a m.call.hangup for the new call
      return;
    }
    state = CallStateData(
      callState: CallState.incoming,
      roomId: roomId,
      remoteUserId: userId,
      remoteUserName: userName,
      remoteUserAvatar: userAvatar,
    );
  }

  void answerCall() {
    if (state.callState != CallState.incoming) return;
    state = state.copyWith(callState: CallState.connected);
    // Here we would send m.call.answer
  }

  void hangupCall() {
    if (state.callState == CallState.none) return;
    // Here we would send m.call.hangup
    state = CallStateData();
  }
}

final callServiceProvider = StateNotifierProvider<CallService, CallStateData>((ref) {
  return CallService();
});
