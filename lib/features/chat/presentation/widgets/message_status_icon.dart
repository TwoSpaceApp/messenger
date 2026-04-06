import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/app_colors.dart';

enum MessageStatusVisualState {
  pending,
  sent,
  delivered,
  read,
}

class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({
    required this.isPending,
    required this.isDelivered,
    required this.isRead,
    super.key,
  });

  final bool isPending;
  final bool isDelivered;
  final bool isRead;

  MessageStatusVisualState get state {
    if (isPending) {
      return MessageStatusVisualState.pending;
    }
    if (isRead) {
      return MessageStatusVisualState.read;
    }
    if (isDelivered) {
      return MessageStatusVisualState.delivered;
    }
    return MessageStatusVisualState.sent;
  }

  @override
  Widget build(BuildContext context) {
    final iconData = switch (state) {
      MessageStatusVisualState.pending => Icons.schedule_rounded,
      MessageStatusVisualState.sent => Icons.done_rounded,
      MessageStatusVisualState.delivered => Icons.done_all_rounded,
      MessageStatusVisualState.read => Icons.done_all_rounded,
    };
    final iconColor = switch (state) {
      MessageStatusVisualState.pending =>
        AppColors.ownBubbleText(context).withValues(alpha: 0.56),
      MessageStatusVisualState.read =>
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.92),
      MessageStatusVisualState.sent || MessageStatusVisualState.delivered =>
        AppColors.ownBubbleText(context).withValues(alpha: 0.72),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: Icon(
        key: ValueKey<MessageStatusVisualState>(state),
        iconData,
        size: 15,
        color: iconColor,
      ),
    );
  }
}
