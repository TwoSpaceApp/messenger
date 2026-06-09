import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/navigation/app_route_observer.dart';
import 'package:two_space_app/core/navigation/app_transitions.dart';
import 'package:two_space_app/core/navigation/title_observer.dart';
import 'package:two_space_app/core/widgets/app_shell_frame.dart';
import 'package:two_space_app/features/auth/presentation/screens/biometric_setup_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_email_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_phone_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/login_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/register_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/tfa_setup_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/main_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/account_profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/active_sessions_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/customization_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/dev_menu_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/feedback_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/notifications_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/privacy_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_search_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/storage_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

CustomTransitionPage<void> _buildPage(GoRouterState state, Widget child) {
  return buildAppTransitionPage(
    state: state,
    child: _RouteBackGuard(
      fallbackRoute: _fallbackRouteFor(state.matchedLocation),
      child: child,
    ),
  );
}

NoTransitionPage<void> _buildShellPage(
  GoRouterState state,
  Widget child, {
  required int selectedIndex,
  bool constrainBody = true,
  double maxBodyWidth = UITokens.readableContentMaxWidth,
  bool showMobileNavBar = true,
}) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: _RouteBackGuard(
      fallbackRoute: AppStrings.routeHome,
      child: AppShellFrame(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          final context = rootNavigatorKey.currentContext;
          if (context == null) {
            return;
          }
          context.go(
            switch (index) {
              0 => AppStrings.routeHome,
              1 => AppStrings.routeWidgets,
              2 => AppStrings.routePeople,
              3 => AppStrings.routeSettingsRoot,
              _ => AppStrings.routeHome,
            },
          );
        },
        constrainBody: constrainBody,
        maxBodyWidth: maxBodyWidth,
        showMobileNavBar: showMobileNavBar,
        child: child,
      ),
    ),
  );
}

String _fallbackRouteFor(String matchedLocation) {
  switch (matchedLocation) {
    case AppStrings.routeSplash:
    case AppStrings.routeLogin:
    case AppStrings.routeRegister:
    case AppStrings.routeForgot:
      return AppStrings.routeLogin;
    default:
      return AppStrings.routeHome;
  }
}

class _RouteBackGuard extends StatelessWidget {
  const _RouteBackGuard({required this.fallbackRoute, required this.child});

  final String fallbackRoute;
  final Widget child;

  Future<void> _handleBack(BuildContext context) async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }

    if (GoRouterState.of(context).matchedLocation != fallbackRoute) {
      router.go(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        unawaited(_handleBack(context));
      },
      child: child,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authProvider, (_, _) => refreshNotifier.refresh());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppStrings.routeSplash,
    observers: [appRouteObserver, TitleObserver()],
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthRoute =
          state.matchedLocation == AppStrings.routeLogin ||
          state.matchedLocation == AppStrings.routeRegister ||
          state.matchedLocation == AppStrings.routeForgot;
      final isSplashRoute = state.matchedLocation == AppStrings.routeSplash;

      return authState.when(
        data: (auth) {
          if (isSplashRoute) {
            return auth.isAuthenticated
                ? AppStrings.routeWelcome
                : AppStrings.routeLogin;
          }
          if (!auth.isAuthenticated && !isAuthRoute) {
            return AppStrings.routeLogin;
          }
          if (auth.isAuthenticated && isAuthRoute) {
            return AppStrings.routeWelcome;
          }
          return null;
        },
        loading: () => null,
        error: (_, _) {
          if (FeatureFlags.ignoreServerOffline.value && !isSplashRoute) {
            return null;
          }
          if (isAuthRoute || isSplashRoute) {
            return null;
          }
          return AppStrings.routeLogin;
        },
      );
    },
    routes: [
      GoRoute(
        path: AppStrings.routeSplash,
        pageBuilder: (context, state) =>
            _buildPage(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppStrings.routeLogin,
        pageBuilder: (context, state) => _buildPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppStrings.routeRegister,
        pageBuilder: (context, state) =>
            _buildPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppStrings.routeForgot,
        pageBuilder: (context, state) =>
            _buildPage(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: AppStrings.routeHome,
        pageBuilder: (context, state) => _buildPage(state, const MainScreen()),
      ),
      GoRoute(
        path: AppStrings.routeWidgets,
        pageBuilder: (context, state) =>
            _buildPage(state, const MainScreen(initialIndex: 1)),
      ),
      GoRoute(
        path: AppStrings.routePeople,
        pageBuilder: (context, state) =>
            _buildPage(state, const MainScreen(initialIndex: 2)),
      ),
      GoRoute(
        path: AppStrings.routeSettingsRoot,
        pageBuilder: (context, state) =>
            _buildPage(state, const MainScreen(initialIndex: 3)),
      ),
      GoRoute(
        path: AppStrings.routeWelcome,
        pageBuilder: (context, state) => _buildPage(
          state,
          const _WelcomeRouteLoader(),
        ),
      ),
      GoRoute(
        path: AppStrings.routeCustomization,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const CustomizationScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routePrivacy,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const PrivacyScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeActiveSessions,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const ActiveSessionsScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeAccountSettings,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const AccountSettingsScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeFeedback,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const FeedbackScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeSettingsSearch,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const SettingsSearchScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeProfile,
        pageBuilder: (context, state) {
          final extra = state.extra;
          String? userIdFromExtra;
          String? initialName;
          String? initialAvatar;
          var startInEdit = false;
          if (extra is String) {
            userIdFromExtra = extra;
          } else if (extra is Map) {
            final map = Map<String, dynamic>.from(extra);
            userIdFromExtra = map['userId']?.toString();
            initialName = map['initialName']?.toString();
            initialAvatar = map['initialAvatar']?.toString();
            startInEdit = map['startInEdit'] == true;
          }
          final authState = ref.read(authProvider).whenOrNull(data: (value) => value);
          final userId = userIdFromExtra ?? authState?.userId ?? '';
          final isOwnProfile =
              authState?.userId != null && authState!.userId == userId;

          if (isOwnProfile && !startInEdit) {
            return _buildShellPage(
              state,
              AccountProfileScreen(
                userId: userId,
                embedded: true,
              ),
              selectedIndex: 3,
            );
          }

          return _buildShellPage(
            state,
            ProfileScreen(
              userId: userId,
              initialName: initialName,
              initialAvatar: initialAvatar,
              startInEdit: startInEdit,
              embedded: true,
            ),
            selectedIndex: 3,
          );
        },
      ),
      GoRoute(
        path: AppStrings.routeAccountProfile,
        pageBuilder: (context, state) {
          final authState = ref.read(authProvider).whenOrNull(data: (value) => value);
          final userId = authState?.userId ?? '';
          return _buildShellPage(
            state,
            AccountProfileScreen(
              userId: userId,
              embedded: true,
            ),
            selectedIndex: 3,
          );
        },
      ),
      GoRoute(
        path: AppStrings.routeChangeEmail,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const ChangeEmailScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeChangePhone,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const ChangePhoneScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeTfaSetup,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const TfaSetupScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeBiometricSetup,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const BiometricSetupScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeNotifications,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const NotificationsScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: AppStrings.routeStorage,
        pageBuilder: (context, state) =>
            _buildShellPage(
              state,
              const StorageScreen(embedded: true),
              selectedIndex: 3,
            ),
      ),
      GoRoute(
        path: '${AppStrings.routeChat}/:chatId',
        pageBuilder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final extra = state.extra;
          final chat = extra is Chat
              ? extra
              : Chat(
                  id: chatId,
                  name: chatId,
                  members: const <String>[],
                );
          return _buildShellPage(
            state,
            ChatScreen(chat: chat),
            selectedIndex: 0,
            constrainBody: false,
            showMobileNavBar: false,
          );
        },
      ),
    ],
  );
});

/// Loads user info from the chat service and displays WelcomeScreen.
class _WelcomeRouteLoader extends StatefulWidget {
  const _WelcomeRouteLoader();

  @override
  State<_WelcomeRouteLoader> createState() => _WelcomeRouteLoaderState();
}

class _WelcomeRouteLoaderState extends State<_WelcomeRouteLoader> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget user info loading is intentional
    // ignore: discarded_futures
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final svc = AegisChatService();
      final info = await svc.getOwnUserInfo();
      if (!mounted) {
        return;
      }
      if ((info['id']?.toString().isEmpty ?? true) &&
          (info['username']?.toString().isEmpty ?? true)) {
        _goHome();
        return;
      }
      setState(() => _userInfo = info);
    } catch (_) {
      _goHome();
    }
  }

  void _goHome() {
    if (mounted) {
      GoRouter.of(context).go(AppStrings.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _userInfo;
    if (info == null) {
      return const SplashScreen();
    }
    return WelcomeScreen(
      name: (info['displayName'] ?? info['username'] ?? info['id'] ?? 'User')
          .toString(),
      username: info['username']?.toString(),
      avatarUrl: info['avatarUrl']?.toString(),
      avatarFileId: info['avatarFileId']?.toString(),
      description: info['bio']?.toString(),
      phone: info['phone']?.toString(),
    );
  }
}
