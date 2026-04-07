import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/unread_badge.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
    this.chatUnreadCount = 0,
    super.key,
  });
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int chatUnreadCount;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _isExpanded;
  Timer? _hideTimer;
  Offset? _dragOffset;

  final double _widthExpanded = 344;
  final double _widthCollapsed = 60;
  final double _height = 70;

  @override
  void initState() {
    super.initState();
    _isExpanded = ValueNotifier(true);
    _resetTimer();
  }

  void _resetTimer() {
    _hideTimer?.cancel();
    _isExpanded.value = true;
    final timeout =
        SettingsService.themeNotifier.value.navBarHideTimeoutSeconds;
    _hideTimer = Timer(Duration(seconds: timeout), () {
      if (mounted) _isExpanded.value = false;
    });
  }

  void _onInteraction() {
    _resetTimer();
  }

  Offset _defaultOffset({
    required Size viewport,
    required double width,
    required EdgeInsets padding,
  }) {
    return Offset(
      (viewport.width - width) / 2,
      viewport.height - padding.bottom - _height - 10,
    );
  }

  Offset _clampOffset({
    required Offset offset,
    required Size viewport,
    required double width,
    required EdgeInsets padding,
  }) {
    const minLeft = 8.0;
    final maxLeft = (viewport.width - width - 8).clamp(minLeft, double.infinity);
    final minTop = padding.top + 8;
    final maxTop = (viewport.height - padding.bottom - _height - 8)
        .clamp(minTop, double.infinity);

    return Offset(
      offset.dx.clamp(minLeft, maxLeft),
      offset.dy.clamp(minTop, maxTop),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: _isExpanded,
      builder: (context, expanded, child) {
        final mediaQuery = MediaQuery.of(context);
        final viewport = mediaQuery.size;
        final screenWidth = viewport.width;
        final expandedWidth = (screenWidth - 24).clamp(280.0, _widthExpanded);
        final targetWidth = expanded ? expandedWidth : _widthCollapsed;

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: targetWidth),
          duration: Duration(milliseconds: expanded ? 380 : 280),
          curve: expanded ? Curves.easeOutCubic : Curves.easeInOutCubic,
          builder: (context, animatedWidth, _) {
            final resolvedOffset = _clampOffset(
              offset: _dragOffset ??
                  _defaultOffset(
                    viewport: viewport,
                    width: animatedWidth,
                    padding: mediaQuery.padding,
                  ),
              viewport: viewport,
              width: animatedWidth,
              padding: mediaQuery.padding,
            );
            final colorScheme = Theme.of(context).colorScheme;
            final expandProgress =
                ((animatedWidth - _widthCollapsed) /
                        (expandedWidth - _widthCollapsed))
                    .clamp(0.0, 1.0);
            final expandedContentOpacity = Curves.easeOut.transform(
              ((expandProgress - 0.18) / 0.82).clamp(0.0, 1.0),
            );
            final collapsedIconOpacity = 1 - Curves.easeInOut.transform(
              (expandProgress / 0.55).clamp(0.0, 1.0),
            );

            return Positioned(
              left: resolvedOffset.dx,
              top: resolvedOffset.dy,
              child: GestureDetector(
                onTap: () {
                  if (!expanded) {
                    _onInteraction();
                  }
                },
                onPanStart: (_) => _onInteraction(),
                onPanUpdate: (details) {
                  final current = _clampOffset(
                    offset: _dragOffset ?? resolvedOffset,
                    viewport: viewport,
                    width: animatedWidth,
                    padding: mediaQuery.padding,
                  );
                  setState(
                    () => _dragOffset = _clampOffset(
                      offset: current + details.delta,
                      viewport: viewport,
                      width: animatedWidth,
                      padding: mediaQuery.padding,
                    ),
                  );
                },
                child: Listener(
                  onPointerDown: (_) => _onInteraction(),
                  child: Container(
                    width: animatedWidth,
                    height: _height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.75),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow(context).withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: ColoredBox(
                          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.82),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: collapsedIconOpacity,
                                child: const Icon(Icons.more_horiz, size: 30),
                              ),
                              IgnorePointer(
                                ignoring: expandedContentOpacity < 0.95,
                                child: Opacity(
                                  opacity: expandedContentOpacity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                        width: expandedWidth - 20,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _NavItem(
                                              icon: Icons.chat_bubble_outline,
                                              label: l10n.chatsTitle,
                                              index: 0,
                                              selected: widget.selectedIndex == 0,
                                              badge: widget.chatUnreadCount,
                                              onTap: () => widget.onItemSelected(0),
                                            ),
                                            _NavItem(
                                              icon: Icons.widgets_outlined,
                                              label: l10n.widgetsTitle,
                                              index: 1,
                                              selected: widget.selectedIndex == 1,
                                              onTap: () => widget.onItemSelected(1),
                                            ),
                                            _NavItem(
                                              icon: Icons.groups_2_outlined,
                                              label: l10n.peopleTitle,
                                              index: 2,
                                              selected: widget.selectedIndex == 2,
                                              onTap: () => widget.onItemSelected(2),
                                            ),
                                            _NavItem(
                                              icon: Icons.settings_outlined,
                                              label: l10n.settingsTitle,
                                              index: 3,
                                              selected: widget.selectedIndex == 3,
                                              onTap: () => widget.onItemSelected(3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {
      required this.icon,
      required this.label,
      required this.index,
      required this.selected,
      required this.onTap,
      this.badge = 0,
      });
  final IconData icon;
  final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.92)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UITokens.cornerLg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    right: -12,
                    top: -6,
                    child: UnreadBadge(count: badge),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
