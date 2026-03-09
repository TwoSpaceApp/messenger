import 'package:flutter/material.dart';
import 'package:two_space_app/core/utils/responsive.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/people/presentation/widgets/person_avatar.dart';

class PersonTile extends StatelessWidget {
  const PersonTile({
    required this.person,
    required this.subtitle,
    required this.onTap,
    required this.onFavoriteTap,
    super.key,
    this.onMessageTap,
    this.onVoiceCallTap,
    this.onVideoCallTap,
    this.onInviteTap,
    this.trailingLabel,
  });

  final PersonEntry person;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onVoiceCallTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onInviteTap;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final iconSize = 20.s(context);
    final badgeHorizontal = 8.s(context);
    final badgeVertical = 4.s(context);

    Widget buildBadge() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: badgeHorizontal,
          vertical: badgeVertical,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          trailingLabel ?? 'TwoSpace',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final actionButtons = <Widget>[
      IconButton(
        visualDensity: VisualDensity.compact,
        iconSize: iconSize,
        splashRadius: 20.s(context),
        onPressed: onFavoriteTap,
        icon: Icon(
          person.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
          color: person.isFavorite ? Colors.amberAccent : Colors.white70,
        ),
      ),
      if (onInviteTap != null)
        IconButton(
          visualDensity: VisualDensity.compact,
          iconSize: iconSize,
          splashRadius: 20.s(context),
          onPressed: onInviteTap,
          icon: const Icon(Icons.share_rounded, color: Colors.white70),
        )
      else ...[
        if (onMessageTap != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: iconSize,
            splashRadius: 20.s(context),
            onPressed: onMessageTap,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white70,
            ),
          ),
        if (onVoiceCallTap != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: iconSize,
            splashRadius: 20.s(context),
            onPressed: onVoiceCallTap,
            icon: const Icon(Icons.call_outlined, color: Colors.white70),
          ),
        if (onVideoCallTap != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: iconSize,
            splashRadius: 20.s(context),
            onPressed: onVideoCallTap,
            icon: const Icon(Icons.videocam_outlined, color: Colors.white70),
          ),
      ],
    ];

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: 8.s(context),
        vertical: 4.s(context),
      ),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.s(context),
          vertical: 6.s(context),
        ),
        child: isCompact
            ? Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PersonAvatar(
                        name: person.displayName,
                        avatarUrl: person.avatarUrl,
                        photoBytes: person.photoBytes,
                        radius: 23.s(context),
                        showOnline: person.isOnline,
                      ),
                      SizedBox(width: 12.s(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    person.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (person.isTwoSpaceUser) buildBadge(),
                              ],
                            ),
                            SizedBox(height: 4.s(context)),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.s(context)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 2.s(context),
                      children: actionButtons,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  PersonAvatar(
                    name: person.displayName,
                    avatarUrl: person.avatarUrl,
                    photoBytes: person.photoBytes,
                    radius: 23.s(context),
                    showOnline: person.isOnline,
                  ),
                  SizedBox(width: 12.s(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                person.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (person.isTwoSpaceUser) buildBadge(),
                          ],
                        ),
                        SizedBox(height: 4.s(context)),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.s(context)),
                  Wrap(children: actionButtons),
                ],
              ),
      ),
    );
  }
}
