import 'dart:async';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/core/widgets/floating_nav_bar.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/calls_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/home_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/contacts_screen.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLocked = false;
  bool _biometricCheckInFlight = false;
  final Set<int> _initializedTabs = <int>{0};
  int _totalUnread = 0;
  StreamSubscription<int>? _unreadSub;

  List<({Widget icon, Widget selectedIcon, String label})> _destinations(
    AppLocalizations l10n,
  ) {
    Widget iconWithBadge(IconData icon, {bool selected = false}) {
      final baseIcon = Icon(icon);
      if (_totalUnread <= 0) {
        return baseIcon;
      }
      return Badge.count(
        count: _totalUnread,
        isLabelVisible: _totalUnread > 0,
        child: baseIcon,
      );
    }

    return [
      (
        icon: iconWithBadge(Icons.chat_bubble_outline_rounded),
        selectedIcon: iconWithBadge(Icons.chat_bubble_rounded, selected: true),
        label: l10n.chatsTitle,
      ),
      (
        icon: const Icon(Icons.call_outlined),
        selectedIcon: const Icon(Icons.call_rounded),
        label: l10n.callsTitle,
      ),
      (
        icon: const Icon(Icons.groups_2_outlined),
        selectedIcon: const Icon(Icons.groups_rounded),
        label: l10n.peopleTitle,
      ),
      (
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings_rounded),
        label: l10n.settingsTitle,
      ),
    ];
  }

  Widget _buildScreen(int index) {
    return switch (index) {
      0 => const HomeScreen(),
      1 => const CallsScreen(),
      2 => const ContactsScreen(),
      3 => const SettingsScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();
    _unreadSub = AegisChatService().watchUnreadChatsCount().listen((total) {
      if (total != _totalUnread && mounted) {
        setState(() => _totalUnread = total);
      }
    });
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometrics();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      AegisChatService().flushNow();
    }
  }

  Future<void> _checkBiometrics() async {
    if (!SettingsService.biometricsNotifier.value) return;

    if (_biometricCheckInFlight) return;
    _biometricCheckInFlight = true;
    if (mounted && !_isLocked) {
      setState(() => _isLocked = true);
    }
    
    try {
      final success = await BiometricService.authenticate(AppLocalizations.of(context)?.unlockApp ?? 'Unlock App');
      if (success && mounted && _isLocked) {
        setState(() => _isLocked = false);
      }
    } finally {
      _biometricCheckInFlight = false;
    }
  }

  void _onTabChanged(int index) {
    if (!_initializedTabs.contains(index)) {
      _initializedTabs.add(index);
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = _destinations(l10n);

    if (_isLocked) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(UITokens.spaceLg),
                  child: SectionCard(
                    radius: UITokens.cornerXL,
                    padding: const EdgeInsets.all(UITokens.spaceXLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 54,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: UITokens.space),
                        Text(
                          l10n.unlockApp,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceSm),
                        Text(
                          l10n.biometricSubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceLg),
                        FilledButton.icon(
                          onPressed: _checkBiometrics,
                          icon: const Icon(Icons.fingerprint_rounded),
                          label: Text(l10n.unlockButton),
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
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= UITokens.tabletBreakpoint;
        final content = IndexedStack(
          index: _currentIndex,
          children: List<Widget>.generate(
            destinations.length,
            (index) => _initializedTabs.contains(index)
                ? _buildScreen(index)
                : const SizedBox.shrink(),
          ),
        );

        if (useRail) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                    child: SectionCard(
                      radius: UITokens.cornerXL,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: NavigationRail(
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _onTabChanged,
                        labelType: NavigationRailLabelType.all,
                        leading: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Icon(
                            Icons.forum_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        destinations: [
                          for (final destination in destinations)
                            NavigationRailDestination(
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                              label: Text(destination.label),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              content,
              FloatingNavBar(
                selectedIndex: _currentIndex,
                onItemSelected: _onTabChanged,
                chatUnreadCount: _totalUnread,
              ),
            ],
          ),
        );
      },
    );
  }
}
