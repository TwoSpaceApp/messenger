import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:two_space_app/services/settings_service.dart';

class FloatingNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar> with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> _isExpanded;
  Timer? _hideTimer;
  Offset _position = const Offset(0, 0); // Relative position
  bool _initialized = false;
  
  // To handle drag limits
  final double _widthExpanded = 280;
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
    final timeout = SettingsService.themeNotifier.value.navBarHideTimeoutSeconds;
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
    final size = MediaQuery.of(context).size;
    
    // Initial centered position at bottom
    if (!_initialized) {
      _position = Offset((size.width - _widthExpanded) / 2, size.height - 100);
      _initialized = true;
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
            // Clamp to screen
            _position = Offset(
              _position.dx.clamp(0, size.width - 60), 
              _position.dy.clamp(0, size.height - 80)
            );
          });
          _onInteraction();
        },
        onTap: () {
          if (!_isExpanded.value) {
            _onInteraction();
          }
        },
        child: Listener( // Catch taps inside
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
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                      child: expanded 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _NavItem(icon: Icons.chat_bubble_outline, index: 0, selected: widget.selectedIndex == 0, onTap: () => widget.onItemSelected(0)),
                              _NavItem(icon: Icons.call_outlined, index: 1, selected: widget.selectedIndex == 1, onTap: () => widget.onItemSelected(1)),
                              _NavItem(icon: Icons.contacts_outlined, index: 2, selected: widget.selectedIndex == 2, onTap: () => widget.onItemSelected(2)),
                              _NavItem(icon: Icons.person_outline, index: 3, selected: widget.selectedIndex == 3, onTap: () => widget.onItemSelected(3)),
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
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          color: selected ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
          size: 26,
        ),
      ),
    );
  }
}
