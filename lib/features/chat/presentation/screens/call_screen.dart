import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class CallScreen extends StatelessWidget {
  final String room;
  final bool isVideo;
  final String? displayName;
  final String? avatarUrl;

  const CallScreen({super.key, required this.room, this.isVideo = false, this.displayName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(isVideo ? l10n.videoCallLabel : l10n.voiceCallLabel)),
      body: Center(child: Text('Call: $room')),
    );
  }
}
