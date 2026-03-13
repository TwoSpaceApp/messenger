import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });
  final int selectedIndex;
  final Function(int) onItemSelected;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _isExpanded;
  Timer? _hideTimer;

  // To handle drag limits
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

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10 + bottomInset,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (!_isExpanded.value) {
              _onInteraction();
            }
          },
          child: Listener(
            onPointerDown: (_) => _onInteraction(),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isExpanded,
              builder: (context, expanded, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack,
                  width: expanded ? _widthExpanded : _widthCollapsed,
                  height: _height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.7),
                        child: expanded
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _NavItem(
                                      icon: Icons.chat_bubble_outline,
                                    label: l10n.chatsTitle,
                                      index: 0,
                                      selected: widget.selectedIndex == 0,
                                      onTap: () => widget.onItemSelected(0)),
                                  _NavItem(
                                      icon: Icons.call_outlined,
                                    label: l10n.callsTitle,
                                      index: 1,
                                      selected: widget.selectedIndex == 1,
                                      onTap: () => widget.onItemSelected(1)),
                                  _NavItem(
                                    icon: Icons.groups_2_outlined,
                                    label: l10n.peopleTitle,
                                      index: 2,
                                      selected: widget.selectedIndex == 2,
                                      onTap: () => widget.onItemSelected(2)),
                                  _NavItem(
                                      icon: Icons.settings_outlined,
                                    label: l10n.settingsTitle,
                                      index: 3,
                                      selected: widget.selectedIndex == 3,
                                      onTap: () => widget.onItemSelected(3)),
                                ],
                              )
                            : const Center(
                                child: Icon(Icons.more_horiz, size: 30),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.index,
      required this.selected,
      required this.onTap});
  final IconData icon;
    final String label;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
