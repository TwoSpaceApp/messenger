// ignore_for_file: unnecessary_underscores

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/sound/audio_player_service.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/widgets/settings_showcase.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  StreamSubscription<void>? _completionSub;
  String? _playingSource;

  @override
  void initState() {
    super.initState();
    _completionSub = _audioPlayer.completionStream.listen((_) {
      if (!mounted) return;
      setState(() => _playingSource = null);
    });
  }

  @override
  void dispose() {
    unawaited(_completionSub?.cancel());
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
    if (_playingSource == path) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() => _playingSource = null);
      return;
    }

    await _audioPlayer.play(path);
    if (!mounted) return;
    setState(() => _playingSource = path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = ListView(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceSm,
        UITokens.spaceMd,
        UITokens.spaceXLg,
      ),
      children: [
        if (widget.embedded) ...[
          SectionPageHeader(
            title: l10n.settingsNotificationNew,
            subtitle: l10n.notificationsHeroSubtitle,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: UITokens.space),
        ],
        ValueListenableBuilder<bool>(
          valueListenable: SettingsService.notificationsEnabledNotifier,
          builder: (context, enabled, _) {
            return SettingsHeroCard(
              icon: enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              title: l10n.settingsNotificationNew,
              subtitle: l10n.notificationsHeroSubtitle,
              badges: [
                _StatusBadge(
                  label: enabled
                      ? l10n.notificationsLabel
                      : l10n.settingsDoNotDisturb,
                  active: enabled,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: UITokens.spaceMd),
        GlassCard(
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.notificationsEnabledNotifier,
                builder: (context, enabled, _) {
                  return _ToggleTile(
                    icon: Icons.notifications_rounded,
                    title: l10n.notificationsLabel,
                    subtitle: l10n.settingsNotificationNew,
                    value: enabled,
                    onChanged: SettingsService.setNotificationsEnabled,
                  );
                },
              ),
              const Divider(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.notificationsEnabledNotifier,
                builder: (context, notificationsEnabled, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: SettingsService.soundEnabledNotifier,
                    builder: (context, enabled, __) {
                      return _ToggleTile(
                        icon: Icons.volume_up_rounded,
                        title: l10n.soundLabel,
                        subtitle: l10n.settingsSoundOptions,
                        value: enabled,
                        onChanged: notificationsEnabled
                            ? SettingsService.setSoundEnabled
                            : null,
                      );
                    },
                  );
                },
              ),
              const Divider(height: 18),
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService.doNotDisturbNotifier,
                builder: (context, enabled, _) {
                  return _ToggleTile(
                    icon: Icons.do_not_disturb_on_total_silence_rounded,
                    title: l10n.settingsDoNotDisturb,
                    subtitle: l10n.notificationsSection,
                    value: enabled,
                    onChanged: SettingsService.setDoNotDisturb,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: UITokens.spaceXLg),
        SettingsSectionHeader(
          title: l10n.soundLabel,
          subtitle: l10n.settingsSoundOptions,
        ),
        const SizedBox(height: UITokens.spaceMdSm),
        ValueListenableBuilder<String?>(
          valueListenable: SettingsService.notificationTonePathNotifier,
          builder: (context, tonePath, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: SettingsService.notificationToneNameNotifier,
              builder: (context, toneName, __) {
                return _SoundCard(
                  icon: Icons.music_note_rounded,
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
                  previewLabel: _playingSource == tonePath
                      ? l10n.stopPreviewLabel
                      : l10n.playPreviewLabel,
                  previewActive: _playingSource == tonePath,
                );
              },
            );
          },
        ),
        const SizedBox(height: UITokens.space),
        ValueListenableBuilder<String?>(
          valueListenable: SettingsService.ringtonePathNotifier,
          builder: (context, ringtonePath, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: SettingsService.ringtoneNameNotifier,
              builder: (context, ringtoneName, __) {
                return _SoundCard(
                  icon: Icons.ring_volume_rounded,
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
                  previewLabel: _playingSource == ringtonePath
                      ? l10n.stopPreviewLabel
                      : l10n.playPreviewLabel,
                  previewActive: _playingSource == ringtonePath,
                );
              },
            );
          },
        ),
      ],
    );

    if (widget.embedded) {
      return list;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsNotificationNew),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(child: list),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fileName,
    required this.onPick,
    required this.onPreview,
    required this.previewLabel,
    required this.previewActive,
    this.onClear,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback? onPreview;
  final String previewLabel;
  final bool previewActive;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.56,
                  ),
                  borderRadius: BorderRadius.circular(UITokens.cornerLg),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: UITokens.space),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: UITokens.spaceXS),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleText(context),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UITokens.spaceMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UITokens.spaceMdSm),
            decoration: BoxDecoration(
              color: previewActive
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.34)
                  : theme.colorScheme.surface.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(UITokens.cornerXLg),
              border: Border.all(
                color: previewActive
                    ? theme.colorScheme.primary.withValues(alpha: 0.22)
                    : theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fileName ?? l10n.customSoundNotSelected,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: fileName == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
                if (previewActive) ...[
                  const SizedBox(width: UITokens.space),
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: UITokens.spaceMdSm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: onClear == null ? double.infinity : null,
                child: OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.library_music_rounded),
                  label: Text(l10n.chooseSoundLabel),
                ),
              ),
              SizedBox(
                width: onClear == null ? double.infinity : null,
                child: FilledButton.icon(
                  onPressed: onPreview,
                  icon: Icon(
                    previewActive
                        ? Icons.stop_circle_outlined
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(previewLabel),
                ),
              ),
              if (onClear != null)
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.clearCustomSoundLabel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(UITokens.cornerMd),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceSmMd,
        vertical: UITokens.spaceXSm,
      ),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.72)
            : theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(UITokens.cornerPill),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: active
              ? theme.colorScheme.primary
              : AppColors.subtitleText(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
