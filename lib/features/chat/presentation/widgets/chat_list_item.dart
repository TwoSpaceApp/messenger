// Chat list item widget with preview and unread badge
import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/aegis_avatar_url.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';

class GradientAvatar extends StatelessWidget {
  const GradientAvatar({
    required this.name,
    super.key,
    this.avatarUrl,
    this.radius = 24.0,
  });
  final String name;
  final String? avatarUrl;
  final double radius;

  List<Color> _generateGradient(String text) {
    if (text.isEmpty) return [Colors.blue, Colors.purple];
    final hash = text.hashCode;

    // Generate saturated, bright colors
    final h1 = (hash % 360).toDouble();
    final h2 = ((hash ~/ 360) % 360).toDouble();

    return [
      HSVColor.fromAHSV(1, h1, 0.7, 0.9).toColor(),
      HSVColor.fromAHSV(1, h2, 0.8, 0.8).toColor(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = normalizeAegisAvatarUrl(avatarUrl);
    if (normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(normalizedAvatarUrl),
      );
    }

    final colors = _generateGradient(name);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    required this.chat,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.onLongPress,
  });
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Chat)? onLongPress;

  String _getPreview(String text, String emptyFallback) {
    if (text.isEmpty) return emptyFallback;
    if (text.length > 50) return '${text.substring(0, 50)}...';
    return text;
  }

  String _formatTime(DateTime? time) {
    return MessageTimeFormatter.formatConversationTime(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final preview = _getPreview(chat.lastMessage, l10n.noMessages);
    final timeStr = _formatTime(chat.lastMessageTime);

    return ListTile(
      selected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress != null ? () => onLongPress!(chat) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Stack(
        children: [
          Hero(
            tag: 'avatar_${chat.id}',
            child: GradientAvatar(
              name: chat.name,
              avatarUrl: chat.avatarUrl,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: chat.unreadCount > 0
                  ? Container(
                      key: ValueKey<int>(chat.unreadCount),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        chat.unreadCount > 99
                            ? '99+'
                            : chat.unreadCount.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey<int>(0)),
            ),
          ),
        ],
      ),
      title: Text(
        chat.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight:
              chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        preview,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
          fontWeight:
              chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeStr,
            style: theme.textTheme.bodySmall,
          ),
          if (chat.members.length > 1) ...[
            const SizedBox(height: 2),
            Text(
              l10n.membersCount(chat.members.length),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
