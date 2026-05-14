import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/core/widgets/app_shell_frame.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/home_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/widgets_screen.dart';
import 'package:two_space_app/features/people/presentation/screens/people_screen.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});
  static const routeName = '/main';

  final int initialIndex;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  late int _currentIndex;
  bool _isLocked = false;
  bool _unlockFailed = false;
  bool _biometricCheckInFlight = false;
  late final Set<int> _initializedTabs;
  int _totalUnread = 0;
  StreamSubscription<int>? _unreadSub;

  Widget _buildScreen(int index) {
    return switch (index) {
      0 => const HomeScreen(),
      1 => const WidgetsScreen(),
      2 => const PeopleScreen(),
      3 => const SettingsScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializedTabs = <int>{widget.initialIndex};
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
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex == widget.initialIndex) {
      return;
    }
    _initializedTabs.add(widget.initialIndex);
    _currentIndex = widget.initialIndex;
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
    if (!SettingsService.biometricsNotifier.value) {
      if (mounted && (_isLocked || _unlockFailed)) {
        setState(() {
          _isLocked = false;
          _unlockFailed = false;
        });
      }
      return;
    }

    if (_biometricCheckInFlight) return;
    _biometricCheckInFlight = true;
    if (mounted && !_isLocked) {
      setState(() {
        _isLocked = true;
        _unlockFailed = false;
      });
    }

    try {
      final success = await BiometricService.authenticate(
        AppLocalizations.of(context)?.unlockApp ?? 'Unlock App',
      );
      if (!mounted) {
        return;
      }

      if (success) {
        setState(() {
          _isLocked = false;
          _unlockFailed = false;
        });
      } else {
        setState(() {
          _isLocked = true;
          _unlockFailed = true;
        });
      }
    } finally {
      _biometricCheckInFlight = false;
    }
  }

  Future<void> _logoutFromLock() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) {
        return;
      }
      context.go(AppStrings.routeLogin);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorLogout(error.toString()))),
      );
    }
  }

  String _routeForIndex(int index) {
    return switch (index) {
      0 => AppStrings.routeHome,
      1 => AppStrings.routeWidgets,
      2 => AppStrings.routePeople,
      3 => AppStrings.routeSettingsRoot,
      _ => AppStrings.routeHome,
    };
  }

  void _onTabChanged(int index) {
    if (!_initializedTabs.contains(index)) {
      _initializedTabs.add(index);
    }
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }

    final route = _routeForIndex(index);
    if (GoRouterState.of(context).matchedLocation != route) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLocked) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: UITokens.dialogMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(UITokens.spaceLg),
                  child: SectionCard(
                    radius: UITokens.cornerXL,
                    padding: const EdgeInsets.all(UITokens.spaceXLg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _unlockFailed
                              ? Icons.error_outline_rounded
                              : Icons.lock_rounded,
                          size: 54,
                          color: _unlockFailed
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(height: UITokens.space),
                        Text(
                          _unlockFailed
                              ? l10n.lockScreenFailedTitle
                              : l10n.unlockApp,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: UITokens.spaceSm),
                        Text(
                          _unlockFailed
                              ? l10n.lockScreenFailedMessage
                              : l10n.biometricSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: _unlockFailed
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: UITokens.spaceLg),
                        FilledButton.icon(
                          onPressed: _biometricCheckInFlight
                              ? null
                              : _checkBiometrics,
                          icon: Icon(
                            _unlockFailed
                                ? Icons.refresh_rounded
                                : Icons.fingerprint_rounded,
                          ),
                          label: Text(
                            _unlockFailed ? l10n.retry : l10n.unlockButton,
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceLg),
                        GestureDetector(
                          onTap: _logoutFromLock,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UITokens.spaceMd,
                              vertical: UITokens.space2XS,
                            ),
                            child: Text(
                              l10n.logoutAction,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
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
    }

    return AppShellFrame(
      selectedIndex: _currentIndex,
      onItemSelected: _onTabChanged,
      chatUnreadCount: _totalUnread,
      child: IndexedStack(
        index: _currentIndex,
        children: List<Widget>.generate(
          4,
          (index) => _initializedTabs.contains(index)
              ? _buildScreen(index)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
