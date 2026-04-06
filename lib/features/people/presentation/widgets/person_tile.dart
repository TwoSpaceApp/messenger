import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/app_colors.dart';
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
    this.onMoreTap,
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
  final VoidCallback? onMoreTap;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 520;
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
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    Widget actionIcon({
      required IconData icon,
      required VoidCallback? onPressed,
      String? tooltip,
      Color? iconColor,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.24),
          ),
        ),
        child: ShadIconButton.ghost(
          width: 36.s(context),
          height: 36.s(context),
          iconSize: iconSize - 1,
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.82),
          ),
        ),
      );
    }

    final inlineActions = <Widget>[
      actionIcon(
        icon:
            person.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        onPressed: onFavoriteTap,
        iconColor: person.isFavorite
            ? AppColors.favoriteActive(context)
            : AppColors.favoriteInactive(context),
      ),
      if (onInviteTap != null)
        actionIcon(
          icon: Icons.share_rounded,
          onPressed: onInviteTap,
        )
      else if (onMessageTap != null)
        actionIcon(
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: onMessageTap,
        ),
      if (onMoreTap != null)
        actionIcon(
          icon: Icons.more_horiz_rounded,
          onPressed: onMoreTap,
        ),
    ];

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: 4.s(context),
        vertical: 2.s(context),
      ),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.s(context),
          vertical: 3.s(context),
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
                        radius: 21.s(context),
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
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
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
                      spacing: 6.s(context),
                      runSpacing: 6.s(context),
                      children: inlineActions,
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
                    radius: 21.s(context),
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
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
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
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.s(context)),
                  Wrap(
                    spacing: 6.s(context),
                    runSpacing: 6.s(context),
                    children: inlineActions,
                  ),
                ],
              ),
      ),
    );
  }
}
