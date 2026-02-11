import 'package:flutter/material.dart';

class ChannelIcon extends StatelessWidget {
  final String channelName;
  final double radius;

  const ChannelIcon({
    super.key,
    required this.channelName,
    this.radius = 18,
  });

  IconData _getIconForChannel(String name) {
    final lowerCaseName = name.toLowerCase();

    if (lowerCaseName.contains('general') || lowerCaseName.contains('main')) {
      return Icons.tag;
    }
    if (lowerCaseName.contains('develop') || lowerCaseName.contains('code')) {
      return Icons.code;
    }
    if (lowerCaseName.contains('design') || lowerCaseName.contains('art')) {
      return Icons.palette_outlined;
    }
    if (lowerCaseName.contains('announcement') || lowerCaseName.contains('news')) {
      return Icons.campaign_outlined;
    }
    if (lowerCaseName.contains('random') || lowerCaseName.contains('offtopic')) {
      return Icons.casino_outlined;
    }
    if (lowerCaseName.contains('music')) {
      return Icons.music_note_outlined;
    }
    if (lowerCaseName.contains('gaming')) {
      return Icons.sports_esports_outlined;
    }
    // Default icon
    return Icons.chat_bubble_outline;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        _getIconForChannel(channelName),
        size: radius * 1.1,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
