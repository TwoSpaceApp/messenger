import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/storage_service.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}



class _StorageScreenState extends State<StorageScreen> {
  final StorageService _storageService = StorageService.instance;

  StorageSnapshot? _snapshot;
  bool _loading = true;
  bool _clearing = false;
  bool _clearPhotos = true;
  bool _clearVideos = true;
  bool _clearFiles = true;
  bool _clearCache = true;
  StorageAutoCleanSettings _autoCleanSettings =
      const StorageAutoCleanSettings();

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    setState(() => _loading = true);
    final settings = await _storageService.loadAutoCleanSettings();
    final snapshot = await _storageService.collectSnapshot();
    if (!mounted) return;
    setState(() {
      _autoCleanSettings = settings;
      _snapshot = snapshot;
      _loading = false;
      _clearPhotos = snapshot.photoBytes > 0;
      _clearVideos = snapshot.videoBytes > 0;
      _clearFiles = snapshot.fileBytes > 0;
      _clearCache = snapshot.cacheBytes > 0;
    });
  }

  int _selectedBytes(StorageSnapshot snapshot) {
    return (_clearPhotos ? snapshot.photoBytes : 0) +
        (_clearVideos ? snapshot.videoBytes : 0) +
        (_clearFiles ? snapshot.fileBytes : 0) +
        (_clearCache ? snapshot.cacheBytes : 0);
  }

  Future<void> _clearSelected() async {
    final snapshot = _snapshot;
    final l10n = AppLocalizations.of(context)!;
    if (snapshot == null || _selectedBytes(snapshot) <= 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _clearing = true);
    await _storageService.clearSelected(
      clearPhotos: _clearPhotos,
      clearVideos: _clearVideos,
      clearFiles: _clearFiles,
      clearCache: _clearCache,
    );
    if (!mounted) return;
    await _loadStorage();
    if (!mounted) return;
    setState(() => _clearing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.cacheCleared)),
    );
  }

  Future<void> _saveAutoCleanSettings(StorageAutoCleanSettings settings) async {
    setState(() => _autoCleanSettings = settings);
    await _storageService.saveAutoCleanSettings(settings);
    if (settings.enabled) {
      await _loadStorage();
    }
  }

  Future<void> _updateAutoCleanTypes(String action) async {
    final next = switch (action) {
      'photos' => _autoCleanSettings.copyWith(
          clearPhotos: !_autoCleanSettings.clearPhotos,
        ),
      'videos' => _autoCleanSettings.copyWith(
          clearVideos: !_autoCleanSettings.clearVideos,
        ),
      'files' => _autoCleanSettings.copyWith(
          clearFiles: !_autoCleanSettings.clearFiles,
        ),
      'cache' => _autoCleanSettings.copyWith(
          clearCache: !_autoCleanSettings.clearCache,
        ),
      'all' => _autoCleanSettings.copyWith(
          clearPhotos: true,
          clearVideos: true,
          clearFiles: true,
          clearCache: true,
        ),
      'none' => _autoCleanSettings.copyWith(
          clearPhotos: false,
          clearVideos: false,
          clearFiles: false,
          clearCache: false,
        ),
      _ => _autoCleanSettings,
    };
    await _saveAutoCleanSettings(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = _snapshot;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.storageMemoryTitle),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _loading || _clearing ? null : _loadStorage,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ScreenBackground(
        child: _loading
            ? const AppLoadingState()
            : snapshot == null
                ? AppEmptyState(
                    title: l10n.nothingFound,
                    message: l10n.noResultsFound,
                    icon: Icons.storage_rounded,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _StorageOverviewCard(snapshot: snapshot),
                      const SizedBox(height: 16),
                      _StorageCleanupSection(
                        snapshot: snapshot,
                        clearPhotos: _clearPhotos,
                        clearVideos: _clearVideos,
                        clearFiles: _clearFiles,
                        clearCache: _clearCache,
                        selectedBytes: _selectedBytes(snapshot),
                        clearing: _clearing,
                        autoCleanSettings: _autoCleanSettings,
                        onPhotosChanged: (value) =>
                            setState(() => _clearPhotos = value),
                        onVideosChanged: (value) =>
                            setState(() => _clearVideos = value),
                        onFilesChanged: (value) =>
                            setState(() => _clearFiles = value),
                        onCacheChanged: (value) =>
                            setState(() => _clearCache = value),
                        onAutoCleanChanged: (value) => _saveAutoCleanSettings(
                          _autoCleanSettings.copyWith(enabled: value),
                        ),
                        onAutoCleanIntervalSelected: (interval) =>
                            _saveAutoCleanSettings(
                          _autoCleanSettings.copyWith(interval: interval),
                        ),
                        onAutoCleanThresholdSelected: (maxBytes) =>
                            _saveAutoCleanSettings(
                          _autoCleanSettings.copyWith(maxBytes: maxBytes),
                        ),
                        onAutoCleanTypesSelected: _updateAutoCleanTypes,
                        onClearPressed: _clearSelected,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _StorageOverviewCard extends StatelessWidget {
  const _StorageOverviewCard({required this.snapshot});

  final StorageSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: _AnimatedStorageRing(snapshot: snapshot),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.storageCleanupSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageCleanupSection extends StatelessWidget {
  const _StorageCleanupSection({
    required this.snapshot,
    required this.clearPhotos,
    required this.clearVideos,
    required this.clearFiles,
    required this.clearCache,
    required this.selectedBytes,
    required this.clearing,
    required this.autoCleanSettings,
    required this.onPhotosChanged,
    required this.onVideosChanged,
    required this.onFilesChanged,
    required this.onCacheChanged,
    required this.onAutoCleanChanged,
    required this.onAutoCleanIntervalSelected,
    required this.onAutoCleanThresholdSelected,
    required this.onAutoCleanTypesSelected,
    required this.onClearPressed,
  });

  final StorageSnapshot snapshot;
  final bool clearPhotos;
  final bool clearVideos;
  final bool clearFiles;
  final bool clearCache;
  final int selectedBytes;
  final bool clearing;
  final StorageAutoCleanSettings autoCleanSettings;
  final ValueChanged<bool> onPhotosChanged;
  final ValueChanged<bool> onVideosChanged;
  final ValueChanged<bool> onFilesChanged;
  final ValueChanged<bool> onCacheChanged;
  final ValueChanged<bool> onAutoCleanChanged;
  final ValueChanged<StorageAutoCleanInterval> onAutoCleanIntervalSelected;
  final ValueChanged<int> onAutoCleanThresholdSelected;
  final ValueChanged<String> onAutoCleanTypesSelected;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.storageCleanupTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.storageCleanupSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StorageSummaryPill(
                  color: theme.colorScheme.primary,
                  icon: Icons.widgets_rounded,
                  label: l10n.storageAppDataLabel,
                  value: StorageService.formatBytes(snapshot.appDataBytes),
                ),
                _StorageSummaryPill(
                  color: const Color(0xFF2F80ED),
                  icon: Icons.photo_library_rounded,
                  label: l10n.storagePhotosLabel,
                  value: StorageService.formatBytes(snapshot.photoBytes),
                ),
                _StorageSummaryPill(
                  color: const Color(0xFFFF7A59),
                  icon: Icons.videocam_rounded,
                  label: l10n.storageVideosLabel,
                  value: StorageService.formatBytes(snapshot.videoBytes),
                ),
                _StorageSummaryPill(
                  color: theme.colorScheme.tertiary,
                  icon: Icons.folder_zip_rounded,
                  label: l10n.filesLabel,
                  value: StorageService.formatBytes(snapshot.fileBytes),
                ),
                _StorageSummaryPill(
                  color: theme.colorScheme.error,
                  icon: Icons.auto_delete_rounded,
                  label: l10n.storageCacheLabel,
                  value: StorageService.formatBytes(snapshot.cacheBytes),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CleanupToggleTile(
              label: l10n.storagePhotosLabel,
              value: StorageService.formatBytes(snapshot.photoBytes),
              icon: Icons.photo_library_rounded,
              color: const Color(0xFF2F80ED),
              selected: clearPhotos,
              enabled: snapshot.photoBytes > 0,
              onChanged: onPhotosChanged,
            ),
            const SizedBox(height: 10),
            _CleanupToggleTile(
              label: l10n.storageVideosLabel,
              value: StorageService.formatBytes(snapshot.videoBytes),
              icon: Icons.videocam_rounded,
              color: const Color(0xFFFF7A59),
              selected: clearVideos,
              enabled: snapshot.videoBytes > 0,
              onChanged: onVideosChanged,
            ),
            const SizedBox(height: 10),
            _CleanupToggleTile(
              label: l10n.filesLabel,
              value: StorageService.formatBytes(snapshot.fileBytes),
              icon: Icons.folder_zip_rounded,
              color: theme.colorScheme.tertiary,
              selected: clearFiles,
              enabled: snapshot.fileBytes > 0,
              onChanged: onFilesChanged,
            ),
            const SizedBox(height: 10),
            _CleanupToggleTile(
              label: l10n.storageCacheLabel,
              value: StorageService.formatBytes(snapshot.cacheBytes),
              icon: Icons.auto_delete_rounded,
              color: theme.colorScheme.error,
              selected: clearCache,
              enabled: snapshot.cacheBytes > 0,
              onChanged: onCacheChanged,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.storageTotalLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          StorageService.formatBytes(selectedBytes),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.storageCleanupSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.storageAutoCleanTitle),
                    subtitle: Text(l10n.storageAutoCleanSubtitle),
                    value: autoCleanSettings.enabled,
                    onChanged: onAutoCleanChanged,
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StorageMenuButton(
                          icon: Icons.event_repeat_rounded,
                          label: l10n.storageAutoCleanPeriodLabel,
                          value: switch (autoCleanSettings.interval) {
                            StorageAutoCleanInterval.daily =>
                              l10n.storageAutoCleanPeriodDaily,
                            StorageAutoCleanInterval.weekly =>
                              l10n.storageAutoCleanPeriodWeekly,
                            StorageAutoCleanInterval.monthly =>
                              l10n.storageAutoCleanPeriodMonthly,
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: StorageAutoCleanInterval.daily,
                              child: Text(l10n.storageAutoCleanPeriodDaily),
                            ),
                            PopupMenuItem(
                              value: StorageAutoCleanInterval.weekly,
                              child: Text(l10n.storageAutoCleanPeriodWeekly),
                            ),
                            PopupMenuItem(
                              value: StorageAutoCleanInterval.monthly,
                              child: Text(l10n.storageAutoCleanPeriodMonthly),
                            ),
                          ],
                          onSelected: onAutoCleanIntervalSelected,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StorageMenuButton(
                          icon: Icons.speed_rounded,
                          label: l10n.storageAutoCleanThresholdLabel,
                          value: StorageService.formatBytes(autoCleanSettings.maxBytes),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 512 * 1024 * 1024, child: Text('512 MB')),
                            PopupMenuItem(value: 1024 * 1024 * 1024, child: Text('1 GB')),
                            PopupMenuItem(value: 2 * 1024 * 1024 * 1024, child: Text('2 GB')),
                            PopupMenuItem(value: 4 * 1024 * 1024 * 1024, child: Text('4 GB')),
                          ],
                          onSelected: onAutoCleanThresholdSelected,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _StorageMenuButton<String>(
                    icon: Icons.tune_rounded,
                    label: l10n.storageAutoCleanTypesLabel,
                    value: [
                      if (autoCleanSettings.clearPhotos) l10n.storagePhotosLabel,
                      if (autoCleanSettings.clearVideos) l10n.storageVideosLabel,
                      if (autoCleanSettings.clearFiles) l10n.filesLabel,
                      if (autoCleanSettings.clearCache) l10n.storageCacheLabel,
                    ].join(', '),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'photos', child: Text(l10n.storagePhotosLabel)),
                      PopupMenuItem(value: 'videos', child: Text(l10n.storageVideosLabel)),
                      PopupMenuItem(value: 'files', child: Text(l10n.filesLabel)),
                      PopupMenuItem(value: 'cache', child: Text(l10n.storageCacheLabel)),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'all',
                        child: Text(l10n.storageAutoCleanSelectAll),
                      ),
                      PopupMenuItem(
                        value: 'none',
                        child: Text(l10n.storageAutoCleanSelectNone),
                      ),
                    ],
                    onSelected: onAutoCleanTypesSelected,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final actionButton = SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        clearing || selectedBytes <= 0 ? null : onClearPressed,
                    icon: clearing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cleaning_services_rounded),
                    label: Text(l10n.settingsStorageClearBtn),
                  ),
                );

                if (constraints.maxWidth < 430) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      actionButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: actionButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageSummaryPill extends StatelessWidget {
  const _StorageSummaryPill({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageMenuButton<T> extends StatelessWidget {
  const _StorageMenuButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.itemBuilder,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final String value;
  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isEmpty ? '—' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }
}

class _CleanupToggleTile extends StatelessWidget {
  const _CleanupToggleTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: enabled && selected,
        onChanged: enabled ? onChanged : null,
        secondary: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _AnimatedStorageRing extends StatelessWidget {
  const _AnimatedStorageRing({required this.snapshot});

  final StorageSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return CustomPaint(
          painter: _StorageRingPainter(
            snapshot: snapshot,
            progress: value,
            theme: Theme.of(context),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.storageTotalLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  StorageService.formatBytes(snapshot.totalBytes),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StorageRingPainter extends CustomPainter {
  const _StorageRingPainter({
    required this.snapshot,
    required this.progress,
    required this.theme,
  });

  final StorageSnapshot snapshot;
  final double progress;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final total = math.max(snapshot.totalBytes, 1);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.08);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    final segments = <({int bytes, Color color})>[
      (bytes: snapshot.appDataBytes, color: theme.colorScheme.primary),
      (bytes: snapshot.photoBytes, color: const Color(0xFF2F80ED)),
      (bytes: snapshot.videoBytes, color: const Color(0xFFFF7A59)),
      (bytes: snapshot.fileBytes, color: theme.colorScheme.tertiary),
      (bytes: snapshot.cacheBytes, color: theme.colorScheme.error),
    ];

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.bytes <= 0) {
        continue;
      }
      final sweep = (segment.bytes / total) * math.pi * 2 * progress;
      glowPaint.color = segment.color.withValues(alpha: 0.18);
      canvas.drawArc(rect, startAngle, sweep, false, glowPaint);
      final segmentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, startAngle, sweep, false, segmentPaint);
      startAngle += (segment.bytes / total) * math.pi * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _StorageRingPainter oldDelegate) {
    return oldDelegate.snapshot != snapshot ||
        oldDelegate.progress != progress ||
        oldDelegate.theme != theme;
  }
}
