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

  Widget _buildBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isInvite = person.isInvitable && !person.isTwoSpaceUser;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.s(context),
        vertical: 5.s(context),
      ),
      decoration: BoxDecoration(
        color: isInvite
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
            : theme.colorScheme.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isInvite
              ? theme.colorScheme.outline.withValues(alpha: 0.18)
              : theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        trailingLabel ?? '',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isInvite
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _actionIcon(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final iconSize = 20.s(context);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 560;

    final inlineActions = <Widget>[
      _actionIcon(
        context,
        icon:
            person.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        onPressed: onFavoriteTap,
        iconColor: person.isFavorite
            ? AppColors.favoriteActive(context)
            : AppColors.favoriteInactive(context),
      ),
      if (onInviteTap != null)
        _actionIcon(
          context,
          icon: Icons.share_rounded,
          onPressed: onInviteTap,
        )
      else if (onMessageTap != null)
        _actionIcon(
          context,
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: onMessageTap,
        ),
      if (onMoreTap != null)
        _actionIcon(
          context,
          icon: Icons.more_horiz_rounded,
          onPressed: onMoreTap,
        ),
    ];

    final identityBadge = trailingLabel == null
        ? null
        : _buildBadge(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.74),
    );

    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: 8.s(context),
        vertical: 8.s(context),
      ),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.s(context),
          vertical: 6.s(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PersonAvatar(
                  name: person.displayName,
                  avatarUrl: person.avatarUrl,
                  photoBytes: person.photoBytes,
                  radius: 22.s(context),
                  showOnline: person.isOnline,
                ),
                SizedBox(width: 12.s(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.s(context)),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.s(context)),
            if (isCompact) ...[
              if (identityBadge != null) ...[
                identityBadge,
                SizedBox(height: 8.s(context)),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 6.s(context),
                  runSpacing: 6.s(context),
                  children: inlineActions,
                ),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: identityBadge == null
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: identityBadge,
                          ),
                  ),
                  Wrap(
                    spacing: 6.s(context),
                    runSpacing: 6.s(context),
                    children: inlineActions,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
