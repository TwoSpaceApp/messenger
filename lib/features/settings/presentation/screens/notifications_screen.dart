import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/sound/audio_player_service.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  bool _playingPreview = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickTone({required bool ringtone}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    final picked = result == null || result.files.isEmpty
        ? null
        : result.files.first;
    final path = picked?.path;
    if (path == null || path.isEmpty) return;
    final displayName = picked?.name ?? File(path).uri.pathSegments.last;

    if (ringtone) {
      await SettingsService.setRingtone(path: path, displayName: displayName);
    } else {
      await SettingsService.setNotificationTone(
        path: path,
        displayName: displayName,
      );
    }
  }

  Future<void> _clearTone({required bool ringtone}) async {
    if (ringtone) {
      await SettingsService.setRingtone(path: null, displayName: null);
    } else {
      await SettingsService.setNotificationTone(path: null, displayName: null);
    }
  }

  Future<void> _togglePreview(String? path) async {
    if (path == null || path.isEmpty) return;
    if (_playingPreview) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() => _playingPreview = false);
      return;
    }

    await _audioPlayer.play(path);
    if (!mounted) return;
    setState(() => _playingPreview = true);
  }

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
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: SettingsService.notificationTonePathNotifier,
              builder: (context, tonePath, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: SettingsService.notificationToneNameNotifier,
                  builder: (context, toneName, __) {
                    return _SoundCard(
                      title: l10n.notificationToneTitle,
                      subtitle: l10n.notificationToneSubtitle,
                      fileName: toneName,
                      onPick: () => _pickTone(ringtone: false),
                      onClear: tonePath == null || tonePath.isEmpty
                          ? null
                          : () => _clearTone(ringtone: false),
                      onPreview: tonePath == null || tonePath.isEmpty
                          ? null
                          : () => _togglePreview(tonePath),
                      previewLabel: _playingPreview
                          ? l10n.stopPreviewLabel
                          : l10n.playPreviewLabel,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String?>(
              valueListenable: SettingsService.ringtonePathNotifier,
              builder: (context, ringtonePath, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: SettingsService.ringtoneNameNotifier,
                  builder: (context, ringtoneName, __) {
                    return _SoundCard(
                      title: l10n.ringtoneTitle,
                      subtitle: l10n.ringtoneSubtitle,
                      fileName: ringtoneName,
                      onPick: () => _pickTone(ringtone: true),
                      onClear: ringtonePath == null || ringtonePath.isEmpty
                          ? null
                          : () => _clearTone(ringtone: true),
                      onPreview: ringtonePath == null || ringtonePath.isEmpty
                          ? null
                          : () => _togglePreview(ringtonePath),
                      previewLabel: _playingPreview
                          ? l10n.stopPreviewLabel
                          : l10n.playPreviewLabel,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.title,
    required this.subtitle,
    required this.fileName,
    required this.onPick,
    required this.onPreview,
    required this.previewLabel,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback? onPreview;
  final String previewLabel;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              fileName ?? l10n.customSoundNotSelected,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: fileName == null ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.library_music_rounded),
                  label: Text(l10n.chooseSoundLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(previewLabel),
                ),
              ),
            ],
          ),
          if (onClear != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.clearCustomSoundLabel),
            ),
          ],
        ],
      ),
    );
  }
}
