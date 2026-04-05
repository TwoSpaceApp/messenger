import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/floating_nav_bar.dart';

class AppShellFrame extends StatelessWidget {
  const AppShellFrame({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
    super.key,
    this.chatUnreadCount = 0,
    this.constrainBody = false,
    this.maxBodyWidth = UITokens.contentMaxWidth,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget child;
  final int chatUnreadCount;
  final bool constrainBody;
  final double maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final useWideNav = mediaQuery.size.width >= UITokens.tabletBreakpoint;

    final content = constrainBody
        ? _ConstrainedShellBody(
            useWideNav: useWideNav,
            maxBodyWidth: maxBodyWidth,
            child: child,
          )
        : Positioned.fill(child: child);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (constrainBody)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundGradientStart(context),
                    AppColors.backgroundGradientEnd(context),
                  ],
                ),
              ),
            ),
          ),
        content,
        if (useWideNav)
          Positioned(
            left: 16,
            top: 16,
            bottom: 16,
            child: _WideNavBar(
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
              chatUnreadCount: chatUnreadCount,
            ),
          )
        else
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: Stack(
                children: [
                  FloatingNavBar(
                    selectedIndex: selectedIndex,
                    onItemSelected: onItemSelected,
                    chatUnreadCount: chatUnreadCount,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ConstrainedShellBody extends StatelessWidget {
  const _ConstrainedShellBody({
    required this.useWideNav,
    required this.maxBodyWidth,
    required this.child,
  });

  final bool useWideNav;
  final double maxBodyWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final horizontalPadding = useWideNav ? 28.0 : 16.0;
    final topPadding = useWideNav ? 20.0 : 12.0;
    final bottomPadding = useWideNav
        ? 24.0
        : mediaQuery.padding.bottom + 112.0;
    final leftPadding = useWideNav ? 148.0 : horizontalPadding;

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          leftPadding,
          topPadding,
          horizontalPadding,
          bottomPadding,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBodyWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}


class _WideNavBar extends StatelessWidget {
  const _WideNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.chatUnreadCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final int chatUnreadCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 124,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context).withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
              child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Center(child: AppLogo(large: false)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _WideNavItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    selectedIcon: Icons.chat_bubble_rounded,
                    label: l10n.chatsTitle,
                    selected: selectedIndex == 0,
                    badge: chatUnreadCount,
                    onTap: () => onItemSelected(0),
                  ),
                  const SizedBox(height: 6),
                  _WideNavItem(
                    icon: Icons.widgets_outlined,
                    selectedIcon: Icons.widgets_rounded,
                    label: l10n.widgetsTitle,
                    selected: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  const SizedBox(height: 6),
                  _WideNavItem(
                    icon: Icons.groups_2_outlined,
                    selectedIcon: Icons.groups_rounded,
                    label: l10n.peopleTitle,
                    selected: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  const SizedBox(height: 6),
                  _WideNavItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    label: l10n.settingsTitle,
                    selected: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WideNavItem extends StatelessWidget {
  const _WideNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer.withValues(alpha: 0.94)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(selected ? selectedIcon : icon, color: foreground),
                  if (badge > 0)
                    Positioned(
                      right: -12,
                      top: -6,
                      child: _WideBadge(count: badge),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideBadge extends StatelessWidget {
  const _WideBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
