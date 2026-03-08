import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/features/auth/presentation/screens/login_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/register_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_email_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_phone_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/tfa_setup_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/main_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/customization_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/privacy_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/feedback_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppStrings.routeHome,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == AppStrings.routeLogin ||
                          state.matchedLocation == AppStrings.routeRegister ||
                          state.matchedLocation == AppStrings.routeForgot;

      return authState.when(
        data: (auth) {
          if (!auth.isAuthenticated && !isAuthRoute) {
            return AppStrings.routeLogin;
          }
          if (auth.isAuthenticated && isAuthRoute) {
            return AppStrings.routeHome;
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => AppStrings.routeLogin,
      );
    },
    routes: [
      GoRoute(
        path: AppStrings.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppStrings.routeRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppStrings.routeForgot,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppStrings.routeHome,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: AppStrings.routeCustomization,
        builder: (context, state) => const CustomizationScreen(),
      ),
      GoRoute(
        path: AppStrings.routePrivacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppStrings.routeAccountSettings,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: AppStrings.routeFeedback,
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: AppStrings.routeProfile,
        builder: (context, state) {
          final id = state.extra as String? ?? '';
          return ProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: AppStrings.routeChangeEmail,
        builder: (context, state) => const ChangeEmailScreen(),
      ),
      GoRoute(
        path: '/change_phone',
        builder: (context, state) => const ChangePhoneScreen(),
      ),
      GoRoute(
        path: '/tfa_setup',
        builder: (context, state) => const TfaSetupScreen(),
      ),
      GoRoute(
        path: AppStrings.routeChat,
        builder: (context, state) {
          final chat = state.extra as Chat?;
          if (chat == null) {
            return const Scaffold(body: Center(child: Text('Chat not found')));
          }
          return ChatScreen(chat: chat);
        },
      ),
    ],
  );
});
