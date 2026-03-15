import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

class SettingsSearchEntry {
  const SettingsSearchEntry({
    required this.title,
    required this.subtitle,
    required this.section,
    required this.icon,
    required this.keywords,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String section;
  final IconData icon;
  final List<String> keywords;
  final Future<void> Function(BuildContext context) onTap;

  String get searchText =>
      '$title $subtitle $section ${keywords.join(' ')}'.toLowerCase();
}

List<SettingsSearchEntry> buildSettingsSearchEntries(AppLocalizations l10n) {
  return [
    SettingsSearchEntry(
      title: l10n.themeLabel,
      subtitle: l10n.settingsThemeSelection,
      section: l10n.appearanceSection,
      icon: Icons.dark_mode,
      keywords: const ['theme', 'appearance', 'light', 'dark', 'system'],
      onTap: (context) async => context.pop(),
    ),
    SettingsSearchEntry(
      title: l10n.customizationLabel,
      subtitle: l10n.customizationSubtitle,
      section: l10n.appearanceSection,
      icon: Icons.palette,
      keywords: const ['font', 'color', 'ui', 'customization', 'effects'],
      onTap: (context) async => context.push(AppStrings.routeCustomization),
    ),
    SettingsSearchEntry(
      title: l10n.settingsNotificationNew,
      subtitle: l10n.notificationsSection,
      section: l10n.notificationsSection,
      icon: Icons.notifications,
      keywords: const ['notifications', 'sound', 'mute', 'dnd'],
      onTap: (context) async => context.push(AppStrings.routeNotifications),
    ),
    SettingsSearchEntry(
      title: l10n.profileLabel,
      subtitle: l10n.profileSubtitle,
      section: l10n.accountSection,
      icon: Icons.person,
      keywords: const ['profile', 'user', 'avatar', 'name'],
      onTap: (context) async {
        final userId = await AuthService().getCurrentUserId();
        if (context.mounted && userId != null) {
          context.push(AppStrings.routeProfile, extra: userId);
        }
      },
    ),
    SettingsSearchEntry(
      title: l10n.accountSettingsLabel,
      subtitle: l10n.accountSettingsSubtitle,
      section: l10n.accountSection,
      icon: Icons.manage_accounts,
      keywords: const ['account', 'password', 'email', 'phone'],
      onTap: (context) async => context.push(AppStrings.routeAccountSettings),
    ),
    SettingsSearchEntry(
      title: l10n.privacyLabel,
      subtitle: l10n.privacySubtitle,
      section: l10n.accountSection,
      icon: Icons.lock,
      keywords: const ['privacy', 'biometric', 'session', '2fa', 'security'],
      onTap: (context) async => context.push(AppStrings.routePrivacy),
    ),
    SettingsSearchEntry(
      title: l10n.languageLabel,
      subtitle: l10n.generalSection,
      section: l10n.generalSection,
      icon: Icons.language,
      keywords: const ['language', 'locale', 'translation'],
      onTap: (context) async => context.pop(),
    ),
    SettingsSearchEntry(
      title: l10n.timestampPrecisionLabel,
      subtitle: l10n.timestampPrecisionSubtitle,
      section: l10n.generalSection,
      icon: Icons.schedule_rounded,
      keywords: const ['time', 'timestamp', 'seconds', 'milliseconds', 'chat'],
      onTap: (context) async => context.pop(),
    ),
    SettingsSearchEntry(
      title: l10n.sendByEnterLabel,
      subtitle: l10n.sendByEnterSubtitle,
      section: l10n.generalSection,
      icon: Icons.keyboard,
      keywords: const ['enter', 'keyboard', 'send'],
      onTap: (context) async => context.pop(),
    ),
    SettingsSearchEntry(
      title: l10n.autoDownloadLabel,
      subtitle: l10n.autoDownloadSubtitle,
      section: l10n.dataStorageSection,
      icon: Icons.download,
      keywords: const ['media', 'download', 'auto', 'files'],
      onTap: (context) async => context.pop(),
    ),
    SettingsSearchEntry(
      title: l10n.storageManagementLabel,
      subtitle: l10n.storageManagementSubtitle,
      section: l10n.dataStorageSection,
      icon: Icons.storage,
      keywords: const ['storage', 'cache', 'clear', 'files'],
      onTap: (context) async => context.push(AppStrings.routeStorage),
    ),
    SettingsSearchEntry(
      title: l10n.aboutSection,
      subtitle: l10n.clientDescription,
      section: l10n.aboutSection,
      icon: Icons.info,
      keywords: const ['about', 'version', 'application'],
      onTap: (context) async => context.pop(),
    ),
    SettingsSearchEntry(
      title: l10n.suggestImprovementLabel,
      subtitle: l10n.suggestImprovementSubtitle,
      section: l10n.aboutSection,
      icon: Icons.lightbulb_outline,
      keywords: const ['feedback', 'improve', 'suggestion'],
      onTap: (context) async => context.push(AppStrings.routeFeedback),
    ),
  ];
}
