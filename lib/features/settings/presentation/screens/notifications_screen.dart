import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsNotificationNew),
      ),
      body: ScreenBackground(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: SettingsService.notificationsEnabledNotifier,
                  builder: (context, enabled, _) {
                    return SwitchListTile(
                      title: Text(l10n.notificationsLabel),
                      subtitle: Text(l10n.settingsNotificationNew),
                      value: enabled,
                      onChanged: SettingsService.setNotificationsEnabled,
                    );
                  },
                ),
                const Divider(height: 1),
                ValueListenableBuilder<bool>(
                  valueListenable: SettingsService.notificationsEnabledNotifier,
                  builder: (context, notificationsEnabled, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: SettingsService.soundEnabledNotifier,
                      builder: (context, enabled, __) {
                        return SwitchListTile(
                          title: Text(l10n.soundLabel),
                          subtitle: Text(l10n.settingsSoundOptions),
                          value: enabled,
                          onChanged: notificationsEnabled
                              ? SettingsService.setSoundEnabled
                              : null,
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                ValueListenableBuilder<bool>(
                  valueListenable: SettingsService.doNotDisturbNotifier,
                  builder: (context, enabled, _) {
                    return SwitchListTile(
                      title: Text(l10n.settingsDoNotDisturb),
                      subtitle: Text(l10n.notificationsSection),
                      value: enabled,
                      onChanged: SettingsService.setDoNotDisturb,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
