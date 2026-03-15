import 'dart:math';

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
  bool _clearMedia = true;
  bool _clearFiles = true;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    setState(() => _loading = true);
    final snapshot = await _storageService.collectSnapshot();
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
      if (snapshot.mediaBytes == 0) _clearMedia = false;
      if (snapshot.fileBytes == 0) _clearFiles = false;
    });
  }

  Future<void> _clearSelected() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_clearMedia && !_clearFiles) return;
    final width = MediaQuery.of(context).size.width;
    final horizontalInset = (width * 0.08).clamp(12.0, 28.0);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        insetPadding:
            EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 24),
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _clearing = true);
    await _storageService.clearSelected(
      clearMedia: _clearMedia,
      clearFiles: _clearFiles,
    );
    if (!mounted) return;
    await _loadStorage();
    if (!mounted) return;
    setState(() => _clearing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.cacheCleared)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snapshot = _snapshot;
    final theme = Theme.of(context);
    final appColor = theme.colorScheme.primary;
    final mediaColor = theme.colorScheme.error;
    final filesColor = theme.colorScheme.tertiary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsStorageManagement),
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsStorageUsage,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: CustomPaint(
                                painter: StoragePieChart(
                                  snapshot: snapshot,
                                  appColor: appColor,
                                  mediaColor: mediaColor,
                                  filesColor: filesColor,
                                  trackColor: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        StorageService.formatBytes(
                                          snapshot.totalBytes,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(l10n.settingsStorageUsage),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StorageTile(
                      color: appColor,
                      title: l10n.settingsStorageAppSize,
                      value: StorageService.formatBytes(snapshot.appDataBytes),
                      icon: Icons.phone_iphone_rounded,
                    ),
                    const SizedBox(height: 12),
                    _StorageSelectionTile(
                      color: mediaColor,
                      title: l10n.mediaLabel,
                      value: StorageService.formatBytes(snapshot.mediaBytes),
                      icon: Icons.perm_media_rounded,
                      selected: _clearMedia,
                      enabled: snapshot.mediaBytes > 0,
                      onChanged: (value) =>
                          setState(() => _clearMedia = value ?? false),
                    ),
                    const SizedBox(height: 12),
                    _StorageSelectionTile(
                      color: filesColor,
                      title: l10n.filesLabel,
                      value: StorageService.formatBytes(snapshot.fileBytes),
                      icon: Icons.folder_copy_rounded,
                      selected: _clearFiles,
                      enabled: snapshot.fileBytes > 0,
                      onChanged: (value) =>
                          setState(() => _clearFiles = value ?? false),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _clearing || (!_clearMedia && !_clearFiles)
                            ? null
                            : _clearSelected,
                        icon: _clearing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cleaning_services_rounded),
                        label: Text(l10n.settingsStorageClearBtn),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class StoragePieChart extends CustomPainter {
  const StoragePieChart({
    required this.snapshot,
    required this.appColor,
    required this.mediaColor,
    required this.filesColor,
    required this.trackColor,
  });

  final StorageSnapshot snapshot;
  final Color appColor;
  final Color mediaColor;
  final Color filesColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = snapshot.totalBytes;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;

    paint.color = trackColor;
    canvas.drawArc(rect, 0, pi * 2, false, paint);

    if (total <= 0) return;

    final segments = [
      (snapshot.appDataBytes, appColor),
      (snapshot.mediaBytes, mediaColor),
      (snapshot.fileBytes, filesColor),
    ];

    var startAngle = -pi / 2;
    for (final segment in segments) {
      final bytes = segment.$1;
      if (bytes <= 0) continue;
      final sweep = (bytes / total) * pi * 2;
      paint.color = segment.$2;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant StoragePieChart oldDelegate) {
    return oldDelegate.snapshot != snapshot ||
        oldDelegate.appColor != appColor ||
        oldDelegate.mediaColor != mediaColor ||
        oldDelegate.filesColor != filesColor ||
        oldDelegate.trackColor != trackColor;
  }
}

class _StorageTile extends StatelessWidget {
  const _StorageTile({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
  });

  final Color color;
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _StorageSelectionTile extends StatelessWidget {
  const _StorageSelectionTile({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final Color color;
  final String title;
  final String value;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: CheckboxListTile(
        value: enabled && selected,
        onChanged: enabled ? onChanged : null,
        secondary: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(value),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
