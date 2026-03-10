import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/navigation/app_transitions.dart';
import 'package:two_space_app/core/navigation/title_observer.dart';
import 'package:two_space_app/features/auth/presentation/screens/biometric_setup_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_email_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_phone_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/login_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/register_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/tfa_setup_screen.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/main_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
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
  return buildAppTransitionPage(state: state, child: child);
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authProvider, (_, __) => refreshNotifier.refresh());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppStrings.routeSplash,
    observers: [TitleObserver()],
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthRoute = state.matchedLocation == AppStrings.routeLogin ||
          state.matchedLocation == AppStrings.routeRegister ||
          state.matchedLocation == AppStrings.routeForgot;
      final isSplashRoute = state.matchedLocation == AppStrings.routeSplash;

      return authState.when(
        data: (auth) {
          if (isSplashRoute) {
            return auth.isAuthenticated
                ? AppStrings.routeHome
                : AppStrings.routeLogin;
          }
          if (!auth.isAuthenticated && !isAuthRoute) {
            return AppStrings.routeLogin;
          }
          if (auth.isAuthenticated && isAuthRoute) {
            return AppStrings.routeHome;
          }
          return null;
        },
        loading: () => null,
        error: (_, __) {
          if (FeatureFlags.ignoreServerOffline.value && !isSplashRoute) {
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
        path: AppStrings.routeCustomization,
        pageBuilder: (context, state) =>
            _buildPage(state, const CustomizationScreen()),
      ),
      GoRoute(
        path: AppStrings.routePrivacy,
        pageBuilder: (context, state) =>
            _buildPage(state, const PrivacyScreen()),
      ),
      GoRoute(
        path: AppStrings.routeAccountSettings,
        pageBuilder: (context, state) =>
            _buildPage(state, const AccountSettingsScreen()),
      ),
      GoRoute(
        path: AppStrings.routeFeedback,
        pageBuilder: (context, state) =>
            _buildPage(state, const FeedbackScreen()),
      ),
      GoRoute(
        path: AppStrings.routeSettingsSearch,
        pageBuilder: (context, state) =>
            _buildPage(state, const SettingsSearchScreen()),
      ),
      GoRoute(
        path: AppStrings.routeProfile,
        pageBuilder: (context, state) {
          final id = state.extra as String? ?? '';
          return _buildPage(state, ProfileScreen(userId: id));
        },
      ),
      GoRoute(
        path: AppStrings.routeChangeEmail,
        pageBuilder: (context, state) =>
            _buildPage(state, const ChangeEmailScreen()),
      ),
      GoRoute(
        path: AppStrings.routeChangePhone,
        pageBuilder: (context, state) =>
            _buildPage(state, const ChangePhoneScreen()),
      ),
      GoRoute(
        path: AppStrings.routeTfaSetup,
        pageBuilder: (context, state) =>
            _buildPage(state, const TfaSetupScreen()),
      ),
      GoRoute(
        path: AppStrings.routeBiometricSetup,
        pageBuilder: (context, state) =>
            _buildPage(state, const BiometricSetupScreen()),
      ),
      GoRoute(
        path: AppStrings.routeNotifications,
        pageBuilder: (context, state) =>
            _buildPage(state, const NotificationsScreen()),
      ),
      GoRoute(
        path: AppStrings.routeStorage,
        pageBuilder: (context, state) =>
            _buildPage(state, const StorageScreen()),
      ),
      GoRoute(
        path: AppStrings.routeChat,
        pageBuilder: (context, state) {
          final chat = state.extra as Chat?;
          if (chat == null) {
            return _buildPage(
              state,
              const Scaffold(body: Center(child: Text('Chat not found'))),
            );
          }
          return _buildPage(state, ChatScreen(chat: chat));
        },
      ),
    ],
  );
});
