import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:two_space_app/services/call_service.dart';
import 'package:two_space_app/widgets/user_avatar.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    // Set the stream sources when the widget initializes
    final callStateData = ref.read(callServiceProvider);
    _localRenderer.srcObject = callStateData.localStream;
    _remoteRenderer.srcObject = callStateData.remoteStream;
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callStateData = ref.watch(callServiceProvider);
    final remoteUserName = callStateData.remoteUserName ?? 'Unknown';

    // Update the renderer sources if the streams change
    if (_localRenderer.srcObject != callStateData.localStream) {
      _localRenderer.srcObject = callStateData.localStream;
    }
    if (_remoteRenderer.srcObject != callStateData.remoteStream) {
      _remoteRenderer.srcObject = callStateData.remoteStream;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video view (main view)
            Positioned.fill(
              child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),

            // Local video view (picture-in-picture)
            if (!callStateData.isScreenSharing)
              Positioned(
                top: 20,
                right: 20,
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                  ),
                ),
              ),

            // UI Controls overlay
            Column(
              children: [
                // Remote user info (now more of a top bar)
                ListTile(
                  leading: UserAvatar(
                    avatarUrl: callStateData.remoteUserAvatar,
                    name: remoteUserName,
                    radius: 24,
                  ),
                  title: Text(
                    remoteUserName,
                    style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _getCallStatusText(callStateData.callState),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),

                const Spacer(), // Pushes controls to the bottom

                // Call controls
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: _buildCallControls(context, ref, callStateData),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControls(BuildContext context, WidgetRef ref, CallStateData callStateData) {
    if (callStateData.callState == CallState.incoming) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: Icons.call_end,
            text: 'Decline',
            color: Colors.red,
            onPressed: () {
              ref.read(callServiceProvider.notifier).hangupCall();
            },
          ),
          _buildControlButton(
            icon: Icons.call,
            text: 'Answer',
            color: Colors.green,
            onPressed: () {
              ref.read(callServiceProvider.notifier).answerCall();
            },
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildControlButton(
          icon: Icons.mic_off_outlined,
          onPressed: () {
            // Toggle mute
          },
        ),
        _buildControlButton(
          icon: Icons.volume_up_outlined,
          onPressed: () {
            // Toggle speakerphone
          },
        ),
        _buildControlButton(
          icon: callStateData.isScreenSharing ? Icons.stop_screen_share_outlined : Icons.screen_share_outlined,
          onPressed: () {
            ref.read(callServiceProvider.notifier).toggleScreenShare(!callStateData.isScreenSharing);
          },
        ),
        _buildControlButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () {
            ref.read(callServiceProvider.notifier).hangupCall();
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? text,
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: text ?? icon.toString(),
          onPressed: onPressed,
          backgroundColor: color == Colors.red || color == Colors.green ? color : Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        if (text != null) ...[
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ]
      ],
    );
  }

  String _getCallStatusText(CallState state) {
    switch (state) {
      case CallState.outgoing:
        return 'Calling...';
      case CallState.incoming:
        return 'Incoming call...';
      case CallState.connected:
        return 'Connected';
      default:
        return '';
    }
  }
}
