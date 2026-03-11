import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/language_switcher.dart';
import 'package:two_space_app/core/widgets/theme_switcher.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loggingOut = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = info.version);
    } catch (_) {
      if (mounted) setState(() => _appVersion = '?');
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logoutDialogTitle),
        content: Text(l10n.logoutDialogContent),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logoutAction,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loggingOut = true);
    try {
      final auth = AuthService();
      await auth.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLogout(e.toString()))));
      setState(() => _loggingOut = false);
    }
  }

  String _timestampPrecisionLabel(
    AppLocalizations l10n,
    MessageTimestampPrecision precision,
  ) {
    switch (precision) {
      case MessageTimestampPrecision.minutes:
        return l10n.timestampPrecisionMinutes;
      case MessageTimestampPrecision.seconds:
        return l10n.timestampPrecisionSeconds;
      case MessageTimestampPrecision.milliseconds:
        return l10n.timestampPrecisionMilliseconds;
    }
  }

  Future<void> _openTimestampPrecisionPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ValueListenableBuilder<MessageTimestampPrecision>(
          valueListenable: SettingsService.messageTimestampPrecisionNotifier,
          builder: (context, current, _) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.timestampPrecisionLabel,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.timestampPrecisionSubtitle,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...MessageTimestampPrecision.values.map((precision) {
                      final selected = precision == current;
                      final sample = MessageTimeFormatter.formatTime(
                        DateTime(2026, 1, 1, 9, 41, 27, 128),
                        precision: precision,
                      );
                      return ListTile(
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        title: Text(
                          _timestampPrecisionLabel(l10n, precision),
                        ),
                        subtitle: Text(sample),
                        onTap: () async {
                          await SettingsService.setMessageTimestampPrecision(
                            precision,
                          );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () => context.push(AppStrings.routeSettingsSearch),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.appearanceSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: ValueListenableBuilder<ThemeMode>(
                          valueListenable: SettingsService.themeModeNotifier,
                          builder: (context, mode, _) {
                            return Icon(mode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode);
                          },
                        ),
                        title: Text(l10n.themeLabel),
                        trailing: const ThemeSwitcherButton(),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.palette),
                        title: Text(l10n.customizationLabel),
                        subtitle: Text(l10n.customizationSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push(AppStrings.routeCustomization),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
              ),

              // Notifications
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.notificationsSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(l10n.settingsNotificationNew),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push(AppStrings.routeNotifications),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ValueListenableBuilder<bool>(
                        valueListenable: SettingsService.doNotDisturbNotifier,
                        builder: (context, enabled, _) {
                          return SwitchListTile(
                            secondary: const Icon(Icons.do_not_disturb),
                            title: Text(l10n.settingsDoNotDisturb),
                            value: enabled,
                            onChanged: SettingsService.setDoNotDisturb,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Account
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.accountSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(l10n.profileLabel),
                        subtitle: Text(l10n.profileSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final auth = AuthService();
                          final userId = await auth.getCurrentUserId();
                          if (userId != null && context.mounted) {
                            context.push('/profile', extra: userId);
                          }
                        },
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.manage_accounts),
                        title: Text(l10n.accountSettingsLabel),
                        subtitle: Text(l10n.accountSettingsSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push(AppStrings.routeAccountSettings),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: Text(l10n.privacyLabel),
                        subtitle: Text(l10n.privacySubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppStrings.routePrivacy),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
              ),

              // General
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.generalSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(l10n.languageLabel),
                        trailing: const LanguageSwitcherButton(),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ValueListenableBuilder<MessageTimestampPrecision>(
                        valueListenable:
                            SettingsService.messageTimestampPrecisionNotifier,
                        builder: (context, precision, _) {
                          return ListTile(
                            isThreeLine: true,
                            leading: const Icon(Icons.schedule_rounded),
                            title: Text(l10n.timestampPrecisionLabel),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(l10n.timestampPrecisionSubtitle),
                                const SizedBox(height: 4),
                                Text(
                                  _timestampPrecisionLabel(l10n, precision),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _openTimestampPrecisionPicker,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: SettingsService.sendByEnterNotifier,
                        builder: (context, sendByEnter, _) {
                          return SwitchListTile(
                            secondary: const Icon(Icons.keyboard),
                            title: Text(l10n.sendByEnterLabel),
                            subtitle: Text(l10n.sendByEnterSubtitle),
                            value: sendByEnter,
                            onChanged: SettingsService.setSendByEnter,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Data & Storage
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.dataStorageSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable:
                            SettingsService.autoDownloadMediaNotifier,
                        builder: (context, autoDownloadMedia, _) {
                          return SwitchListTile(
                            secondary: const Icon(Icons.download),
                            title: Text(l10n.autoDownloadLabel),
                            subtitle: Text(l10n.autoDownloadSubtitle),
                            value: autoDownloadMedia,
                            onChanged: SettingsService.setAutoDownloadMedia,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.memory_rounded),
                        title: Text(l10n.settingsStorageUsage),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppStrings.routeStorage),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.storage),
                        title: Text(l10n.storageManagementLabel),
                        subtitle: Text(l10n.storageManagementSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppStrings.routeStorage),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
              ),
              // About
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.aboutSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: Text(l10n.appTitle),
                        subtitle: Text(
                            _appVersion.isEmpty ? l10n.loading : _appVersion),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lightbulb_outline),
                        title: Text(l10n.suggestImprovementLabel),
                        subtitle: Text(l10n.suggestImprovementSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppStrings.routeFeedback),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
              ),

              // Danger zone
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.dangerZoneSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _loggingOut ? null : _logout,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red.shade400),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.logoutLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.red.shade400,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    l10n.logoutSubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color:
                                              Colors.red.withValues(alpha: 0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (_loggingOut)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
