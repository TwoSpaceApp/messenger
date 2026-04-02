import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';

class StartChatBottomSheet extends StatelessWidget {
  const StartChatBottomSheet({
    required this.onCreateGroup,
    required this.onInviteUser,
    required this.onJoinByAddress,
    super.key,
  });
  final VoidCallback onCreateGroup;
  final VoidCallback onInviteUser;
  final VoidCallback onJoinByAddress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: GlassCard(
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.startChatTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              context,
              icon: Icons.add_circle_outline,
              title: l10n.createNewRoomTitle,
              subtitle: l10n.createRoomSubtitle,
              onTap: () {
                Navigator.pop(context);
                onCreateGroup();
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: Icons.person_add_alt_1_outlined,
              title: l10n.inviteUserTitle,
              subtitle: l10n.inviteUserSubtitle,
              onTap: () {
                Navigator.pop(context);
                onInviteUser();
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              context,
              icon: Icons.link_outlined,
              title: l10n.joinByCodeTitle,
              subtitle: l10n.joinByCodeSubtitle,
              onTap: () {
                Navigator.pop(context);
                onJoinByAddress();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ShadButton.secondary(
      width: double.infinity,
      height: 84,
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
