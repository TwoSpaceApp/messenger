import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsNotificationNew),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.notificationsLabel),
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.soundLabel),
                  value: true,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
