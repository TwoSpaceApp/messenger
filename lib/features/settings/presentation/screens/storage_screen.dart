import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/storage_service.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final StorageService _storageService = StorageService.instance;
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      final snapshot = await _storageService.collectSnapshot();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _clearPhotos = _clearPhotos && snapshot.photoBytes > 0;
        _clearVideos = _clearVideos && snapshot.videoBytes > 0;
        _clearFiles = _clearFiles && snapshot.fileBytes > 0;
        _clearCache = _clearCache && snapshot.cacheBytes > 0;
      });
    }
  }

  Future<void> _pickAutoCleanInterval() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(UITokens.corner2XL),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHandle(theme: theme),
                _SheetHeader(
                  icon: Icons.event_repeat_rounded,
                  title: l10n.storageAutoCleanPeriodLabel,
                  subtitle: l10n.storageAutoCleanSubtitle,
                ),
                ...StorageAutoCleanInterval.values.map((interval) {
                  final selected = interval == _autoCleanSettings.interval;
                  return ListTile(
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    title: Text(switch (interval) {
                      StorageAutoCleanInterval.daily =>
                        l10n.storageAutoCleanPeriodDaily,
                      StorageAutoCleanInterval.weekly =>
                        l10n.storageAutoCleanPeriodWeekly,
                      StorageAutoCleanInterval.monthly =>
                        l10n.storageAutoCleanPeriodMonthly,
                    }),
                    onTap: () async {
                      await _saveAutoCleanSettings(
                        _autoCleanSettings.copyWith(interval: interval),
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  );
                }),
                const SizedBox(height: UITokens.spaceSm),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAutoCleanThreshold() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    const options = [
      512 * 1024 * 1024,
      1024 * 1024 * 1024,
      2 * 1024 * 1024 * 1024,
      4 * 1024 * 1024 * 1024,
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(UITokens.corner2XL),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHandle(theme: theme),
                _SheetHeader(
                  icon: Icons.speed_rounded,
                  title: l10n.storageAutoCleanThresholdLabel,
                  subtitle: l10n.storageAutoCleanSubtitle,
                ),
                ...options.map((value) {
                  final selected = value == _autoCleanSettings.maxBytes;
                  return ListTile(
                    leading: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    title: Text(StorageService.formatBytes(value)),
                    onTap: () async {
                      await _saveAutoCleanSettings(
                        _autoCleanSettings.copyWith(maxBytes: value),
                      );
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  );
                }),
                const SizedBox(height: UITokens.spaceSm),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAutoCleanTypes() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    var clearPhotos = _autoCleanSettings.clearPhotos;
    var clearVideos = _autoCleanSettings.clearVideos;
    var clearFiles = _autoCleanSettings.clearFiles;
    var clearCache = _autoCleanSettings.clearCache;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(UITokens.corner2XL),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SheetHandle(theme: theme),
                    _SheetHeader(
                      icon: Icons.tune_rounded,
                      title: l10n.storageAutoCleanTypesLabel,
                      subtitle: l10n.storageAutoCleanSubtitle,
                    ),
                    CheckboxListTile(
                      value: clearPhotos,
                      onChanged: (value) =>
                          setSheetState(() => clearPhotos = value ?? false),
                      title: Text(l10n.storagePhotosLabel),
                    ),
                    CheckboxListTile(
                      value: clearVideos,
                      onChanged: (value) =>
                          setSheetState(() => clearVideos = value ?? false),
                      title: Text(l10n.storageVideosLabel),
                    ),
                    CheckboxListTile(
                      value: clearFiles,
                      onChanged: (value) =>
                          setSheetState(() => clearFiles = value ?? false),
                      title: Text(l10n.filesLabel),
                    ),
                    CheckboxListTile(
                      value: clearCache,
                      onChanged: (value) =>
                          setSheetState(() => clearCache = value ?? false),
                      title: Text(l10n.storageCacheLabel),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        UITokens.spaceMd,
                        UITokens.spaceSm,
                        UITokens.spaceMd,
                        UITokens.spaceMd,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setSheetState(() {
                                  clearPhotos = true;
                                  clearVideos = true;
                                  clearFiles = true;
                                  clearCache = true;
                                });
                              },
                              child: Text(l10n.storageAutoCleanSelectAll),
                            ),
                          ),
                          const SizedBox(width: UITokens.spaceSmMd),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                await _saveAutoCleanSettings(
                                  _autoCleanSettings.copyWith(
                                    clearPhotos: clearPhotos,
                                    clearVideos: clearVideos,
                                    clearFiles: clearFiles,
                                    clearCache: clearCache,
                                  ),
                                );
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                              },
                              child: Text(l10n.save),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final snapshot = _snapshot;

    final body = _loading
        ? const AppLoadingState()
        : snapshot == null
        ? AppEmptyState(
            title: l10n.nothingFound,
            message: l10n.noResultsFound,
            icon: Icons.storage_rounded,
          )
        : ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              UITokens.spaceMd,
              UITokens.spaceSm,
              UITokens.spaceMd,
              UITokens.spaceXLg,
            ),
            children: [
              _StorageOverviewCard(snapshot: snapshot),
              const SizedBox(height: UITokens.spaceMd),
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
                onFilesChanged: (value) => setState(() => _clearFiles = value),
                onCacheChanged: (value) => setState(() => _clearCache = value),
                onAutoCleanChanged: (value) => _saveAutoCleanSettings(
                  _autoCleanSettings.copyWith(enabled: value),
                ),
                onAutoCleanIntervalPressed: _pickAutoCleanInterval,
                onAutoCleanThresholdPressed: _pickAutoCleanThreshold,
                onAutoCleanTypesPressed: _pickAutoCleanTypes,
                onClearPressed: _clearSelected,
              ),
            ],
          );

    final content = Column(
      children: [
        if (widget.embedded)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UITokens.spaceMd,
              UITokens.spaceSm,
              UITokens.spaceMd,
              UITokens.space,
            ),
            child: SectionPageHeader(
              title: l10n.storageMemoryTitle,
              subtitle: l10n.storageCleanupSubtitle,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              actions: [
                IconButton(
                  onPressed: _loading || _clearing ? null : _loadStorage,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        Expanded(child: body),
      ],
    );

    if (widget.embedded) {
      return content;
    }

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
      body: ScreenBackground(child: body),
    );
  }
}

class _StorageOverviewCard extends StatelessWidget {
  const _StorageOverviewCard({required this.snapshot});

  final StorageSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(UITokens.spaceLg),
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: _AnimatedStorageRing(snapshot: snapshot),
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
    required this.onAutoCleanIntervalPressed,
    required this.onAutoCleanThresholdPressed,
    required this.onAutoCleanTypesPressed,
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
  final VoidCallback onAutoCleanIntervalPressed;
  final VoidCallback onAutoCleanThresholdPressed;
  final VoidCallback onAutoCleanTypesPressed;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final materialL10n = MaterialLocalizations.of(context);
    final lastRun = autoCleanSettings.lastRun;
    final selectedLabels = [
      if (clearPhotos) l10n.storagePhotosLabel,
      if (clearVideos) l10n.storageVideosLabel,
      if (clearFiles) l10n.filesLabel,
      if (clearCache) l10n.storageCacheLabel,
    ];
    final lastRunLabel = lastRun == null
        ? l10n.storageAutoCleanLastRunNever
        : '${materialL10n.formatCompactDate(lastRun)} • '
              '${materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(lastRun))}';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(UITokens.spaceMdLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.storageCleanupTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: UITokens.spaceXSm),
            Text(
              l10n.storageCleanupSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            _CleanupToggleTile(
              label: l10n.storagePhotosLabel,
              value: StorageService.formatBytes(snapshot.photoBytes),
              icon: Icons.photo_library_rounded,
              color: const Color(0xFF2F80ED),
              selected: clearPhotos,
              enabled: snapshot.photoBytes > 0,
              onChanged: onPhotosChanged,
            ),
            const SizedBox(height: UITokens.spaceSmMd),
            _CleanupToggleTile(
              label: l10n.storageVideosLabel,
              value: StorageService.formatBytes(snapshot.videoBytes),
              icon: Icons.videocam_rounded,
              color: const Color(0xFFFF7A59),
              selected: clearVideos,
              enabled: snapshot.videoBytes > 0,
              onChanged: onVideosChanged,
            ),
            const SizedBox(height: UITokens.spaceSmMd),
            _CleanupToggleTile(
              label: l10n.filesLabel,
              value: StorageService.formatBytes(snapshot.fileBytes),
              icon: Icons.folder_zip_rounded,
              color: theme.colorScheme.tertiary,
              selected: clearFiles,
              enabled: snapshot.fileBytes > 0,
              onChanged: onFilesChanged,
            ),
            const SizedBox(height: UITokens.spaceSmMd),
            _CleanupToggleTile(
              label: l10n.storageCacheLabel,
              value: StorageService.formatBytes(snapshot.cacheBytes),
              icon: Icons.auto_delete_rounded,
              color: theme.colorScheme.error,
              selected: clearCache,
              enabled: snapshot.cacheBytes > 0,
              onChanged: onCacheChanged,
            ),
            const SizedBox(height: UITokens.spaceMd),
            Container(
              padding: const EdgeInsets.all(UITokens.spaceMdSm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.32,
                ),
                borderRadius: BorderRadius.circular(UITokens.cornerXLg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.storageSelectedLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceXS),
                        Text(
                          StorageService.formatBytes(selectedBytes),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: UITokens.space),
                  Expanded(
                    child: Text(
                      selectedLabels.isEmpty ? '—' : selectedLabels.join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.72,
                        ),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            GlassCard(
              child: AnimatedContainer(
                duration: UITokens.durationMd,
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(UITokens.spaceMdSm),
                decoration: BoxDecoration(
                  color: autoCleanSettings.enabled
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.28,
                        )
                      : theme.colorScheme.surface.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(UITokens.cornerXLg),
                  border: Border.all(
                    color: autoCleanSettings.enabled
                        ? theme.colorScheme.primary.withValues(alpha: 0.16)
                        : theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.storageAutoCleanTitle),
                      subtitle: Text(
                        autoCleanSettings.enabled
                            ? l10n.storageAutoCleanStatusEnabled
                            : l10n.storageAutoCleanStatusDisabled,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.subtitleText(context),
                        ),
                      ),
                      value: autoCleanSettings.enabled,
                      onChanged: onAutoCleanChanged,
                    ),
                    const Divider(height: 16),
                    _StorageSheetField(
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
                      onTap: onAutoCleanIntervalPressed,
                    ),
                    const SizedBox(height: UITokens.spaceSm),
                    _StorageSheetField(
                      icon: Icons.speed_rounded,
                      label: l10n.storageAutoCleanThresholdLabel,
                      value: StorageService.formatBytes(
                        autoCleanSettings.maxBytes,
                      ),
                      onTap: onAutoCleanThresholdPressed,
                    ),
                    const SizedBox(height: UITokens.spaceSm),
                    _StorageSheetField(
                      icon: Icons.tune_rounded,
                      label: l10n.storageAutoCleanTypesLabel,
                      value: [
                        if (autoCleanSettings.clearPhotos)
                          l10n.storagePhotosLabel,
                        if (autoCleanSettings.clearVideos)
                          l10n.storageVideosLabel,
                        if (autoCleanSettings.clearFiles) l10n.filesLabel,
                        if (autoCleanSettings.clearCache) l10n.storageCacheLabel,
                      ].join(', '),
                      onTap: onAutoCleanTypesPressed,
                    ),
                    const SizedBox(height: UITokens.spaceSm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StorageSummaryPill(
                          color: theme.colorScheme.primary,
                          icon: Icons.history_rounded,
                          label: l10n.storageAutoCleanLastRunLabel,
                          value: lastRunLabel,
                        ),
                        _StorageSummaryPill(
                          color: theme.colorScheme.tertiary,
                          icon: Icons.speed_rounded,
                          label: l10n.storageAutoCleanThresholdLabel,
                          value: StorageService.formatBytes(
                            autoCleanSettings.maxBytes,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            LayoutBuilder(
              builder: (context, constraints) {
                final actionButton = SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: clearing || selectedBytes <= 0
                        ? null
                        : onClearPressed,
                    icon: clearing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: UITokens.borderThick,
                            ),
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

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UITokens.space,
          vertical: UITokens.spaceSmMd,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(UITokens.cornerLg),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: UITokens.spaceSm),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageSheetField extends StatelessWidget {
  const _StorageSheetField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(UITokens.space),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(UITokens.cornerLg),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Tooltip(
                message: label,
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: UITokens.space),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: UITokens.spaceSm),
              const Icon(Icons.expand_more_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: UITokens.space),
      width: UITokens.dragHandleWidth,
      height: UITokens.dragHandleHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(UITokens.corner2XS),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceLg,
        0,
        UITokens.spaceLg,
        UITokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UITokens.spaceSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(UITokens.corner),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: UITokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: UITokens.spaceXS),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(UITokens.cornerXLg),
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
      duration: UITokens.duration3Lg,
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
                const SizedBox(height: UITokens.spaceSm),
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
