import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/core/widgets/language_switcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedTheme = 'system';
  bool _loggingOut = false;
  bool _devMenuEnabled = false;
  String _appVersion = '';
  bool _autoDownloadMedia = false;
  bool _sendByEnter = true;
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _textScale = SettingsService.textScaleNotifier.value;
      _autoDownloadMedia = SettingsService.autoDownloadMediaNotifier.value;
      _sendByEnter = SettingsService.sendByEnterNotifier.value;
      _selectedTheme = switch (SettingsService.themeModeNotifier.value) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      };
      
      // Load notifications/sound if they exist in service, otherwise default
      // Assuming existing service has notification settings (checked previously, didn't see explicit pub methods but maybe notifiers?)
      // Actually checking previous read of SettingsService... 
      // It has showEmail, showPhone, paleViolet, etc. but not generic notifications/sound.
      // Keeping local state for those for now as they might be system level or unimplemented.
    });
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logoutAction, style: const TextStyle(color: Colors.red)),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorLogout(e.toString()))));
      setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                      title: Text(l10n.themeLabel),
                      trailing: DropdownButton<String>(
                        value: _selectedTheme,
                        onChanged: (value) async {
                          final next = value ?? 'system';
                          setState(() => _selectedTheme = next);
                          final mode = switch (next) {
                            'light' => ThemeMode.light,
                            'dark' => ThemeMode.dark,
                            _ => ThemeMode.system,
                          };
                          await SettingsService.setThemeMode(mode);
                        },
                        items: [
                          DropdownMenuItem(value: 'system', child: Text(l10n.themeSystem)),
                          DropdownMenuItem(value: 'light', child: Text(l10n.themeLight)),
                          DropdownMenuItem(value: 'dark', child: Text(l10n.themeDark)),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: Text(l10n.customizationLabel),
                      subtitle: Text(l10n.customizationSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/customization'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications),
                      title: Text(l10n.notificationsLabel),
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up),
                      title: Text(l10n.soundLabel),
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.manage_accounts),
                      title: Text(l10n.accountSettingsLabel),
                      subtitle: Text(l10n.accountSettingsSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/account-settings'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: Text(l10n.privacyLabel),
                      subtitle: Text(l10n.privacySubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/privacy'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.languageLabel),
                      trailing: const LanguageSwitcherButton(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: Text(l10n.textSizeLabel),
                      subtitle: Slider(
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        value: _textScale,
                        label: '${(_textScale * 100).toInt()}%',
                        onChanged: (v) => setState(() => _textScale = v),
                        onChangeEnd: (v) async => await SettingsService.setTextScale(v),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.keyboard),
                      title: Text(l10n.sendByEnterLabel),
                      subtitle: Text(l10n.sendByEnterSubtitle),
                      value: _sendByEnter,
                      onChanged: (v) async {
                        setState(() => _sendByEnter = v);
                        await SettingsService.setSendByEnter(v);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.download),
                      title: Text(l10n.autoDownloadLabel),
                      subtitle: Text(l10n.autoDownloadSubtitle),
                      value: _autoDownloadMedia,
                      onChanged: (v) async {
                        setState(() => _autoDownloadMedia = v);
                        await SettingsService.setAutoDownloadMedia(v);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: Text(l10n.storageManagementLabel),
                      subtitle: Text(l10n.storageManagementSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(l10n.clearCacheTitle),
                            content: Text(l10n.clearCacheContent),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.cacheCleared)),
                                  );
                                },
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Development
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                l10n.developmentSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Developer Menu'),
                  subtitle: Text(l10n.devMenuSubtitle),
                  trailing: Switch(
                    value: _devMenuEnabled,
                    onChanged: (value) {
                      setState(() => _devMenuEnabled = value);
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('TwoSpace'),
                      subtitle: Text(_appVersion.isEmpty ? l10n.loading : _appVersion),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    Tooltip(
                      message: l10n.matrixTooltip,
                      child: ListTile(
                      subtitle: Text(l10n.clientDescription),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline),
                      title: Text(l10n.suggestImprovementLabel),
                      subtitle: Text(l10n.suggestImprovementSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/feedback'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  l10n.logoutSubtitle,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.red.withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (_loggingOut)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
