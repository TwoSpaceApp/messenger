import 'package:flutter/material.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/services/update_service.dart';
import 'package:two_space_app/features/auth/presentation/screens/biometric_setup_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_email_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/change_phone_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/login_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/register_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/sso_webview_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/tfa_setup_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/advanced_search_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/call_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/calls_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_settings_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_channel_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_group_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/group_settings_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/home_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/join_room_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/main_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/account_settings_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/contacts_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/search_contacts_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/customization_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/feedback_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/notifications_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/privacy_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/storage_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/update_screen.dart';

class DevScreenEntry {
  const DevScreenEntry({
    required this.title,
    required this.source,
    required this.group,
    required this.builder,
  });

  final String title;
  final String source;
  final String group;
  final WidgetBuilder builder;

  String get searchText => '$title $source $group'.toLowerCase();
}

abstract final class DevScreenCatalog {
  static final List<DevScreenEntry> entries = <DevScreenEntry>[
    DevScreenEntry(
      title: 'AccountSettingsScreen',
      source: 'profile/account_settings_screen.dart',
      group: 'Profile',
      builder: (_) => const AccountSettingsScreen(),
    ),
    DevScreenEntry(
      title: 'AdvancedSearchScreen',
      source: 'chat/advanced_search_screen.dart',
      group: 'Chat',
      builder: (_) => const AdvancedSearchScreen(),
    ),
    DevScreenEntry(
      title: 'BiometricSetupScreen',
      source: 'auth/biometric_setup_screen.dart',
      group: 'Auth',
      builder: (_) => const BiometricSetupScreen(),
    ),
    DevScreenEntry(
      title: 'CallScreen',
      source: 'chat/call_screen.dart',
      group: 'Chat',
      builder: (_) => const CallScreen(
        room: '!debug-room:twospace.dev',
        displayName: 'Debug Call',
      ),
    ),
    DevScreenEntry(
      title: 'CallsScreen',
      source: 'chat/calls_screen.dart',
      group: 'Chat',
      builder: (_) => const CallsScreen(),
    ),
    DevScreenEntry(
      title: 'ChangeEmailScreen',
      source: 'auth/change_email_screen.dart',
      group: 'Auth',
      builder: (_) => const ChangeEmailScreen(),
    ),
    DevScreenEntry(
      title: 'ChangePhoneScreen',
      source: 'auth/change_phone_screen.dart',
      group: 'Auth',
      builder: (_) => const ChangePhoneScreen(),
    ),
    DevScreenEntry(
      title: 'ChatScreen',
      source: 'chat/chat_screen.dart',
      group: 'Chat',
      builder: (_) => ChatScreen(
        chat: Chat(
          id: '!debug-chat:twospace.dev',
          name: 'Debug Chat',
          members: const ['@debug:twospace.dev'],
          lastMessage: 'Preview message',
        ),
      ),
    ),
    DevScreenEntry(
      title: 'ChatSettingsScreen',
      source: 'chat/chat_settings_screen.dart',
      group: 'Chat',
      builder: (_) => const ChatSettingsScreen(
        roomId: '!debug-chat:twospace.dev',
        initialName: 'Debug Chat',
      ),
    ),
    DevScreenEntry(
      title: 'ContactsScreen',
      source: 'profile/contacts_screen.dart',
      group: 'Profile',
      builder: (_) => const ContactsScreen(),
    ),
    DevScreenEntry(
      title: 'CreateChatScreen',
      source: 'chat/create_chat_screen.dart',
      group: 'Chat',
      builder: (_) => const CreateChatScreen(),
    ),
    DevScreenEntry(
      title: 'CreateGroupScreen',
      source: 'chat/create_group_screen.dart',
      group: 'Chat',
      builder: (_) => const CreateGroupScreen(),
    ),
    DevScreenEntry(
      title: 'CreateChannelScreen',
      source: 'chat/create_channel_screen.dart',
      group: 'Chat',
      builder: (_) => const CreateChannelScreen(),
    ),
    DevScreenEntry(
      title: 'JoinRoomScreen',
      source: 'chat/join_room_screen.dart',
      group: 'Chat',
      builder: (_) => const JoinRoomScreen(),
    ),
    DevScreenEntry(
      title: 'CustomizationScreen',
      source: 'settings/customization_screen.dart',
      group: 'Settings',
      builder: (_) => const CustomizationScreen(),
    ),
    DevScreenEntry(
      title: 'FeedbackScreen',
      source: 'settings/feedback_screen.dart',
      group: 'Settings',
      builder: (_) => const FeedbackScreen(),
    ),
    DevScreenEntry(
      title: 'ForgotPasswordScreen',
      source: 'auth/forgot_password_screen.dart',
      group: 'Auth',
      builder: (_) => const ForgotPasswordScreen(),
    ),
    DevScreenEntry(
      title: 'GroupSettingsScreen',
      source: 'chat/group_settings_screen.dart',
      group: 'Chat',
      builder: (_) => const GroupSettingsScreen(
        roomId: '!debug-group:twospace.dev',
      ),
    ),
    DevScreenEntry(
      title: 'HomeScreen',
      source: 'chat/home_screen.dart',
      group: 'Chat',
      builder: (_) => const HomeScreen(),
    ),
    DevScreenEntry(
      title: 'LoginScreen',
      source: 'auth/login_screen.dart',
      group: 'Auth',
      builder: (_) => const LoginScreen(),
    ),
    DevScreenEntry(
      title: 'MainScreen',
      source: 'chat/main_screen.dart',
      group: 'Chat',
      builder: (_) => const MainScreen(),
    ),
    DevScreenEntry(
      title: 'NotificationsScreen',
      source: 'settings/notifications_screen.dart',
      group: 'Settings',
      builder: (_) => const NotificationsScreen(),
    ),
    DevScreenEntry(
      title: 'OtpScreen',
      source: 'auth/otp_screen.dart',
      group: 'Auth',
      builder: (_) => const OtpScreen(phone: '+79990000000'),
    ),
    DevScreenEntry(
      title: 'PrivacyScreen',
      source: 'settings/privacy_screen.dart',
      group: 'Settings',
      builder: (_) => const PrivacyScreen(),
    ),
    DevScreenEntry(
      title: 'ProfileScreen',
      source: 'profile/profile_screen.dart',
      group: 'Profile',
      builder: (_) => const ProfileScreen(
        userId: '@debug:twospace.dev',
        initialName: 'Debug User',
      ),
    ),
    DevScreenEntry(
      title: 'RegisterScreen',
      source: 'auth/register_screen.dart',
      group: 'Auth',
      builder: (_) => const RegisterScreen(),
    ),
    DevScreenEntry(
      title: 'SearchContactsScreen',
      source: 'profile/search_contacts_screen.dart',
      group: 'Profile',
      builder: (_) => const SearchContactsScreen(),
    ),
    DevScreenEntry(
      title: 'SettingsScreen',
      source: 'settings/settings_screen.dart',
      group: 'Settings',
      builder: (_) => const SettingsScreen(),
    ),
    DevScreenEntry(
      title: 'SplashScreen',
      source: 'auth/splash_screen.dart',
      group: 'Auth',
      builder: (_) => const SplashScreen(
        currentStep: 'Settings Service',
        progress: 0.6,
      ),
    ),
    DevScreenEntry(
      title: 'SsoWebviewScreen',
      source: 'auth/sso_webview_screen.dart',
      group: 'Auth',
      builder: (_) => const SsoWebviewScreen(idpId: 'debug'),
    ),
    DevScreenEntry(
      title: 'StorageScreen',
      source: 'settings/storage_screen.dart',
      group: 'Settings',
      builder: (_) => const StorageScreen(),
    ),
    DevScreenEntry(
      title: 'TfaSetupScreen',
      source: 'auth/tfa_setup_screen.dart',
      group: 'Auth',
      builder: (_) => const TfaSetupScreen(),
    ),
    DevScreenEntry(
      title: 'UpdateScreen',
      source: 'settings/update_screen.dart',
      group: 'Settings',
      builder: (_) => UpdateScreen(
        info: UpdateInfo(
          latestVersion: '0.0.0-dev',
          updateUrl: 'https://example.com/twospace.apk',
          notes: 'Debug preview build',
        ),
      ),
    ),
    DevScreenEntry(
      title: 'WelcomeScreen',
      source: 'auth/welcome_screen.dart',
      group: 'Auth',
      builder: (_) => const WelcomeScreen(name: 'Developer'),
    ),
  ]..sort((a, b) => a.title.compareTo(b.title));
}
