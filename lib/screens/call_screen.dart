import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/services/call_service.dart';
import 'package:two_space_app/widgets/user_avatar.dart';

class CallScreen extends ConsumerWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callStateData = ref.watch(callServiceProvider);
    final remoteUserName = callStateData.remoteUserName ?? 'Unknown';
    final remoteUserAvatar = callStateData.remoteUserAvatar;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Remote user info
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserAvatar(
                    avatarUrl: remoteUserAvatar,
                    name: remoteUserName,
                    radius: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    remoteUserName,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getCallStatusText(callStateData.callState),
                    style: const TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                ],
              ),
            ),

            // Screen share placeholder
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.screen_share_outlined, color: Colors.white54, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Screen sharing placeholder',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Call controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Row(
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
                    icon: Icons.screen_share_outlined,
                    onPressed: () {
                      // Start/stop screen sharing
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: color == Colors.red ? Colors.red : Colors.white24,
      child: Icon(icon, color: color == Colors.red ? Colors.white : color),
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
