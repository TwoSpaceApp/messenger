// ignore_for_file: unnecessary_underscores

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/dev_log_export_service.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';
import 'package:two_space_app/core/services/dev_sensitive_data_policy.dart';
import 'package:two_space_app/core/services/dev_tools_service.dart';
import 'package:two_space_app/core/services/update_service.dart';
import 'package:two_space_app/core/utils/secure_store.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/highlighted_text.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/screens/dev_screen_catalog.dart';

class FeatureFlags {
  static final ValueNotifier<bool> enableNewChatUI = ValueNotifier(false);
  static final ValueNotifier<bool> forceVideoCompression = ValueNotifier(true);
  static final ValueNotifier<bool> enableAggressiveCaching = ValueNotifier(
    false,
  );
  static final ValueNotifier<bool> ignoreServerOffline = ValueNotifier(false);
}

class DevMenuScreen extends StatefulWidget {
  const DevMenuScreen({super.key});

  @override
  State<DevMenuScreen> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends State<DevMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DevLogger _logger = DevLogger('DevMenu');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.devMenuTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard_customize_outlined),
              text: l10n.devMenuTabActions,
            ),
            Tab(icon: const Icon(Icons.brush_outlined), text: l10n.devMenuTabUiInspect),
            Tab(icon: const Icon(Icons.article_outlined), text: l10n.devMenuTabLogs),
            Tab(icon: const Icon(Icons.network_check), text: l10n.devMenuTabNetwork),
            Tab(icon: const Icon(Icons.flag_outlined), text: l10n.devMenuTabFeatures),
            Tab(icon: const Icon(Icons.info_outline), text: l10n.devMenuTabInfo),
          ],
        ),
      ),
      body: ScreenBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _DevMenuActionsTab(logger: _logger),
            const _DevMenuUIInspectorTab(),
            const _DevMenuLogsTab(),
            const _DevMenuNetworkTab(),
            const _DevMenuFeatureFlagsTab(),
            const _DevMenuInfoTab(),
          ],
        ),
      ),
    );
  }
}

class _DevMenuLogsTab extends StatefulWidget {
  const _DevMenuLogsTab();

  @override
  State<_DevMenuLogsTab> createState() => _DevMenuLogsTabState();
}

class _DevMenuLogsTabState extends State<_DevMenuLogsTab> {
  bool _showOnlyErrors = false;
  bool _oldestFirst = false;
  bool _exporting = false;

  List<String> _visibleLogs(List<String> sourceLogs) {
    final filtered = _showOnlyErrors
        ? sourceLogs
              .where((line) => line.contains(LogLevel.error.emoji))
              .toList(growable: false)
        : sourceLogs;
    if (!_oldestFirst) {
      return filtered;
    }
    return filtered.reversed.toList(growable: false);
  }

  Future<void> _copyVisibleLogs(List<String> logs) async {
    if (logs.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: logs.join('\n')));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.textCopied)));
  }

  Future<void> _exportLogs() async {
    if (_exporting) {
      return;
    }
    setState(() => _exporting = true);
    try {
      final savedPath = await DevLogExportService.exportBundle(
        appLogs: DevLogger.all,
        networkLogs: DevNetworkLogger.instance.logs,
      );
      if (!mounted || savedPath == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fileDownloaded(savedPath)),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.genericError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<String>>(
      stream: DevLogger.stream,
      initialData: DevLogger.all,
      builder: (context, snapshot) {
        final sourceLogs = snapshot.data ?? const <String>[];
        final logs = _visibleLogs(sourceLogs);

        if (logs.isEmpty) {
          return AppEmptyState(
            title: l10n.devMenuLogsEmptyTitle,
            message: l10n.devMenuLogsEmptyMessage,
            icon: Icons.receipt_long_outlined,
            actionLabel: sourceLogs.isNotEmpty ? l10n.devMenuShowAll : null,
            onAction: sourceLogs.isNotEmpty
                ? () => setState(() => _showOnlyErrors = false)
                : null,
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UITokens.space,
                UITokens.space,
                UITokens.space,
                UITokens.spaceSm,
              ),
              child: Wrap(
                spacing: UITokens.spaceSm,
                runSpacing: UITokens.spaceSm,
                children: [
                  FilterChip(
                    label: Text(
                      _showOnlyErrors
                          ? l10n.devMenuOnlyErrors
                          : l10n.devMenuAllEntries(sourceLogs.length.toString()),
                    ),
                    selected: _showOnlyErrors,
                    onSelected: (value) =>
                        setState(() => _showOnlyErrors = value),
                  ),
                  ChoiceChip(
                    label: Text(
                      _oldestFirst
                          ? l10n.devMenuOldestFirst
                          : l10n.devMenuNewestFirst,
                    ),
                    selected: _oldestFirst,
                    onSelected: (value) => setState(() => _oldestFirst = value),
                  ),
                  TextButton.icon(
                    onPressed: logs.isEmpty ? null : () => _copyVisibleLogs(logs),
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(l10n.devMenuCopyVisible),
                  ),
                  TextButton.icon(
                    onPressed: sourceLogs.isEmpty || _exporting ? null : _exportLogs,
                    icon: _exporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_upload_outlined),
                    label: Text(l10n.devMenuExportLogFile),
                  ),
                  TextButton.icon(
                    onPressed: sourceLogs.isEmpty ? null : DevLogger.clear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(l10n.devMenuClearAction),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  UITokens.space,
                  0,
                  UITokens.space,
                  UITokens.space,
                ),
                itemCount: logs.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: UITokens.spaceSm),
                itemBuilder: (context, index) {
                  final line = logs[index];
                  final color = _appLogColor(line);
                  return Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(UITokens.cornerMd),
                      border: Border.all(color: color.withValues(alpha: 0.18)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(UITokens.space),
                      child: SelectableText(
                        line,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _appLogColor(String line) {
    if (line.contains(LogLevel.error.emoji)) return Colors.redAccent;
    if (line.contains(LogLevel.warning.emoji)) return Colors.orangeAccent;
    if (line.contains(LogLevel.info.emoji)) return Colors.blueAccent;
    return Colors.white70;
  }
}

class _DevMenuActionsTab extends StatefulWidget {
  const _DevMenuActionsTab({required this.logger});

  final DevLogger logger;

  @override
  State<_DevMenuActionsTab> createState() => _DevMenuActionsTabState();
}

class _DevMenuActionsTabState extends State<_DevMenuActionsTab> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGroup;

  List<DevScreenEntry> get _allScreens => [
    DevScreenEntry(
      title: 'DevMenuScreen',
      source: 'settings/dev_menu_screen.dart',
      group: 'Settings',
      builder: (_) => const DevMenuScreen(),
    ),
    ...DevScreenCatalog.entries,
  ];

  List<String> get _groups =>
      _allScreens.map((entry) => entry.group).toSet().toList()..sort();

  List<DevScreenEntry> get _filteredScreens {
    final query = _searchController.text.trim().toLowerCase();
    return _allScreens.where((entry) {
      if (_selectedGroup != null && entry.group != _selectedGroup) {
        return false;
      }
      if (query.isEmpty) return true;
      return entry.searchText.contains(query);
    }).toList();
  }

  Map<String, List<DevScreenEntry>> get _groupedScreens {
    final map = <String, List<DevScreenEntry>>{};
    for (final entry in _filteredScreens) {
      map.putIfAbsent(entry.group, () => <DevScreenEntry>[]).add(entry);
    }
    final sortedKeys = map.keys.toList()..sort();
    return {for (final key in sortedKeys) key: map[key]!};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupedScreens = _groupedScreens;
    final query = _searchController.text.trim();

    return ListView(
      padding: const EdgeInsets.all(UITokens.spaceMd),
      children: [
        _buildSectionTitle(context, l10n.devMenuScreenExplorerTitle),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l10n.devMenuScreenSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: UITokens.space),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: UITokens.spaceSm),
                child: ChoiceChip(
                  label: Text(l10n.devMenuAllScreens(_allScreens.length.toString())),
                  selected: _selectedGroup == null,
                  onSelected: (_) => setState(() => _selectedGroup = null),
                ),
              ),
              ..._groups.map(
                (group) {
                  final count = _allScreens
                      .where((e) => e.group == group)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: UITokens.spaceSm),
                    child: ChoiceChip(
                      label: Text('$group ($count)'),
                      selected: _selectedGroup == group,
                      onSelected: (_) => setState(() => _selectedGroup = group),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: UITokens.space),
        AnimatedSwitcher(
          duration: UITokens.durationMdSm,
          child: groupedScreens.isEmpty
              ? AppEmptyState(
                  key: const ValueKey('empty-dev-screens'),
                  title: l10n.devMenuScreensNotFoundTitle,
                  message: l10n.devMenuScreensNotFoundMessage,
                  icon: Icons.travel_explore_rounded,
                )
              : Container(
                  key: ValueKey('${query}_${_selectedGroup ?? 'all'}'),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(UITokens.cornerXLg),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (final entry in groupedScreens.entries) ...[
                        _buildGroupHeader(
                          context,
                          entry.key,
                          entry.value.length,
                        ),
                        for (var i = 0; i < entry.value.length; i++) ...[
                          _buildScreenTile(context, entry.value[i], query),
                          if (i != entry.value.length - 1)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        ],
                      ],
                    ],
                  ),
                ),
        ),
        const SizedBox(height: UITokens.spaceXLg),
        _buildSectionTitle(context, l10n.devMenuUtilitiesTitle),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildAction(
              context,
              l10n.devMenuForceCrash,
              Icons.bug_report_outlined,
              () => throw Exception('Test crash triggered from Dev Menu'),
              color: Colors.orange,
            ),
            _buildAction(
              context,
              l10n.devMenuClearSecureStorage,
              Icons.delete_forever_outlined,
              () async {
                await SecureStore.deleteAll();
                widget.logger.info('Secure storage cleared');
              },
              color: Colors.red,
            ),
            _buildAction(
              context,
              l10n.devMenuClearCacheProfile,
              Icons.layers_clear,
              () async {
                await SettingsService.clearCachedProfile();
                widget.logger.info('Profile cache cleared');
              },
              color: Colors.red,
            ),
            _buildAction(
              context,
              l10n.devMenuCheckOta,
              Icons.system_update_alt_rounded,
              () async {
                widget.logger.info('Checking OTA update…');
                await UpdateService.checkForUpdate();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupHeader(BuildContext context, String group, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceMdSm,
        UITokens.spaceMd,
        UITokens.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          Text(
            group,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: UITokens.spaceSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UITokens.spaceSm,
              vertical: UITokens.space2XS,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(UITokens.cornerPill),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTile(
    BuildContext context,
    DevScreenEntry entry,
    String query,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceMd,
        vertical: UITokens.spaceXS,
      ),
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(
          Icons.web_asset_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: HighlightedText(
        entry.title,
        query: query,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: UITokens.spaceXS),
          HighlightedText(
            entry.source,
            query: query,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: UITokens.spaceXSm),
          Text(
            AppLocalizations.of(context)!.devMenuOpenScreen,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: entry.builder),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UITokens.space),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: UITokens.spaceMd,
          vertical: UITokens.space,
        ),
        backgroundColor: color?.withValues(alpha: 0.1),
        foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

class _DevMenuUIInspectorTab extends StatefulWidget {
  const _DevMenuUIInspectorTab();

  @override
  State<_DevMenuUIInspectorTab> createState() => _DevMenuUIInspectorTabState();
}

class _DevMenuUIInspectorTabState extends State<_DevMenuUIInspectorTab> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(UITokens.spaceMd),
      children: [
        SwitchListTile(
          title: Text(l10n.devMenuShowBounds),
          subtitle: Text(l10n.devMenuShowBoundsSubtitle),
          value: debugPaintSizeEnabled,
          onChanged: (val) => setState(() => debugPaintSizeEnabled = val),
        ),
        SwitchListTile(
          title: Text(l10n.devMenuRepaintRainbow),
          subtitle: Text(l10n.devMenuRepaintRainbowSubtitle),
          value: debugRepaintRainbowEnabled,
          onChanged: (val) => setState(() => debugRepaintRainbowEnabled = val),
        ),
        SwitchListTile(
          title: Text(l10n.devMenuSlowAnimations),
          subtitle: Text(l10n.devMenuSlowAnimationsSubtitle),
          value: timeDilation != 1.0,
          onChanged: (val) => setState(() => timeDilation = val ? 5.0 : 1.0),
        ),
        SwitchListTile(
          title: Text(l10n.devMenuPerformanceOverlay),
          subtitle: Text(l10n.devMenuPerformanceOverlaySubtitle),
          value: DevToolsService.performanceOverlayEnabled.value,
          onChanged: (val) => setState(
            () => DevToolsService.performanceOverlayEnabled.value = val,
          ),
        ),
      ],
    );
  }
}

class _DevMenuFeatureFlagsTab extends StatefulWidget {
  const _DevMenuFeatureFlagsTab();

  @override
  State<_DevMenuFeatureFlagsTab> createState() =>
      _DevMenuFeatureFlagsTabState();
}

class _DevMenuFeatureFlagsTabState extends State<_DevMenuFeatureFlagsTab> {
  Future<void> _handleSensitiveToggle(bool value) async {
    if (!DevSensitiveDataPolicy.canRevealSensitiveData) {
      return;
    }

    if (!value) {
      DevSensitiveDataPolicy.setRevealSensitiveData(false);
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.devMenuSensitiveDialogTitle),
          content: Text(l10n.devMenuSensitiveDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.devMenuEnable),
            ),
          ],
        );
      },
    );

    if (approved ?? false) {
      DevSensitiveDataPolicy.setRevealSensitiveData(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(UITokens.spaceMd),
      children: [
        ValueListenableBuilder<bool>(
          valueListenable:
              DevSensitiveDataPolicy.revealSensitiveDataForNewLogs,
          builder: (context, revealSensitiveData, _) {
            final canToggle = DevSensitiveDataPolicy.canRevealSensitiveData;
            final subtitle = canToggle
                ? l10n.devMenuSensitiveEnableDescription
                : l10n.devMenuSensitiveDisabledDescription;
            return SwitchListTile(
              title: Text(l10n.devMenuRevealSensitiveData),
              subtitle: Text(subtitle),
              value: revealSensitiveData,
              onChanged: canToggle ? _handleSensitiveToggle : null,
            );
          },
        ),
        _buildFlagTile(l10n.devMenuFlagNewChatUi, FeatureFlags.enableNewChatUI),
        _buildFlagTile(
          l10n.devMenuFlagForceVideoCompression,
          FeatureFlags.forceVideoCompression,
        ),
        _buildFlagTile(
          l10n.devMenuFlagAggressiveCaching,
          FeatureFlags.enableAggressiveCaching,
        ),
        _buildFlagTile(
          l10n.devMenuFlagIgnoreServerOffline,
          FeatureFlags.ignoreServerOffline,
          subtitle: l10n.devMenuFlagIgnoreServerOfflineSubtitle,
        ),
        if (!kDebugMode)
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(l10n.devMenuReleaseHiddenTitle),
            subtitle: Text(l10n.devMenuReleaseHiddenSubtitle),
          ),
      ],
    );
  }

  Widget _buildFlagTile(
    String title,
    ValueNotifier<bool> flag, {
    String? subtitle,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: flag,
      builder: (context, value, _) {
        return SwitchListTile(
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle),
          value: value,
          onChanged: (val) => flag.value = val,
        );
      },
    );
  }
}

class _DevMenuNetworkTab extends StatefulWidget {
  const _DevMenuNetworkTab();

  @override
  State<_DevMenuNetworkTab> createState() => _DevMenuNetworkTabState();
}

class _DevMenuNetworkTabState extends State<_DevMenuNetworkTab> {
  bool _showOnlyErrors = false;
  bool _oldestFirst = false;
  bool _exporting = false;

  List<DevNetworkLog> _visibleLogs(List<DevNetworkLog> sourceLogs) {
    final filtered = _showOnlyErrors
        ? sourceLogs.where((log) => log.isError).toList(growable: false)
        : sourceLogs;
    if (!_oldestFirst) {
      return filtered;
    }
    return filtered.reversed.toList(growable: false);
  }

  Future<void> _copyVisibleLogs(List<DevNetworkLog> logs) async {
    if (logs.isEmpty) {
      return;
    }
    await Clipboard.setData(
      ClipboardData(text: DevLogExportService.formatNetworkLogs(logs)),
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.textCopied)));
  }

  Future<void> _exportLogs() async {
    if (_exporting) {
      return;
    }
    setState(() => _exporting = true);
    try {
      final savedPath = await DevLogExportService.exportBundle(
        appLogs: DevLogger.all,
        networkLogs: DevNetworkLogger.instance.logs,
      );
      if (!mounted || savedPath == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fileDownloaded(savedPath)),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.genericError(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<DevNetworkLog>>(
      stream: DevNetworkLogger.instance.logsStream,
      initialData: DevNetworkLogger.instance.logs,
      builder: (context, snapshot) {
        final sourceLogs = snapshot.data ?? [];
        final logs = _visibleLogs(sourceLogs);

        if (logs.isEmpty) {
          return AppEmptyState(
            title: l10n.devMenuNetworkEmptyTitle,
            message: l10n.devMenuNetworkEmptyMessage,
            icon: Icons.wifi_find_rounded,
            actionLabel: sourceLogs.isNotEmpty ? l10n.devMenuShowAll : null,
            onAction: sourceLogs.isNotEmpty
                ? () => setState(() => _showOnlyErrors = false)
                : null,
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UITokens.space,
                UITokens.space,
                UITokens.space,
                UITokens.spaceSm,
              ),
              child: Wrap(
                spacing: UITokens.spaceSm,
                runSpacing: UITokens.spaceSm,
                children: [
                  FilterChip(
                    label: Text(
                      _showOnlyErrors
                          ? l10n.devMenuOnlyErrors
                          : l10n.devMenuAllRequests(sourceLogs.length.toString()),
                    ),
                    selected: _showOnlyErrors,
                    onSelected: (value) =>
                        setState(() => _showOnlyErrors = value),
                  ),
                  ChoiceChip(
                    label: Text(
                      _oldestFirst
                          ? l10n.devMenuOldestFirst
                          : l10n.devMenuNewestFirst,
                    ),
                    selected: _oldestFirst,
                    onSelected: (value) => setState(() => _oldestFirst = value),
                  ),
                  TextButton.icon(
                    onPressed: logs.isEmpty ? null : () => _copyVisibleLogs(logs),
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(l10n.devMenuCopyVisible),
                  ),
                  TextButton.icon(
                    onPressed: sourceLogs.isEmpty || _exporting ? null : _exportLogs,
                    icon: _exporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_upload_outlined),
                    label: Text(l10n.devMenuExportLogFile),
                  ),
                  TextButton.icon(
                    onPressed: sourceLogs.isEmpty
                        ? null
                        : DevNetworkLogger.instance.clear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(l10n.devMenuClearAction),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: UITokens.borderThin),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final color = _colorFor(log);

                  return ColoredBox(
                    color: color.withValues(alpha: 0.035),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            UITokens.cornerSmMd,
                          ),
                          border: Border.all(
                            color: color.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Text(
                          log.method,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      title: Text(
                        log.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildMetaChip(log.statusLabel, color),
                          _buildMetaChip(log.kindLabel, color),
                          _buildMetaChip(
                            '${log.latencyMs} ms',
                            Colors.blueGrey,
                          ),
                          _buildMetaChip(
                            log.responseTypeLabel,
                            Colors.deepPurple,
                          ),
                        ],
                      ),
                      children: [
                        _buildDetailsHeader(context, log, color),
                        if (log.requestHeaders.isNotEmpty)
                          _buildCodeBlock(
                            l10n.devMenuRequestHeaders,
                            log.requestHeaders,
                            accent: Colors.lightBlueAccent,
                          ),
                        if (log.requestBody != null)
                          _buildCodeBlock(
                            l10n.devMenuRequestBody(log.requestTypeLabel),
                            log.requestBody,
                            accent: Colors.orangeAccent,
                          ),
                        if (log.responseHeaders.isNotEmpty)
                          _buildCodeBlock(
                            l10n.devMenuResponseHeaders,
                            log.responseHeaders,
                            accent: Colors.cyanAccent,
                          ),
                        if (log.responseBody != null ||
                            log.errorMessage != null)
                          _buildCodeBlock(
                            l10n.devMenuResponseBody(log.responseTypeLabel),
                            log.errorMessage ?? log.responseBody,
                            accent: log.isError
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailsHeader(
    BuildContext context,
    DevNetworkLog log,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${log.timestamp.toLocal()}'.split('.').first,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          Text(
            log.isError
                ? l10n.devMenuNetworkProblemDetected
                : l10n.devMenuNetworkCompleted,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UITokens.cornerPill),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCodeBlock(String title, dynamic data, {required Color accent}) {
    var pretty = '';
    try {
      if (data is Map || data is List) {
        pretty = const JsonEncoder.withIndent('  ').convert(data);
      } else {
        pretty = data.toString();
      }
    } catch (_) {
      pretty = data.toString();
    }

    return Padding(
      padding: const EdgeInsets.all(UITokens.space),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: accent,
            ),
          ),
          const SizedBox(height: UITokens.spaceXS),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UITokens.spaceSm),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(UITokens.cornerSm),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: SelectableText(
              pretty,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(DevNetworkLog log) {
    switch (log.kind) {
      case DevNetworkLogKind.success:
        return Colors.green;
      case DevNetworkLogKind.redirect:
        return Colors.amber;
      case DevNetworkLogKind.clientError:
        return Colors.orange;
      case DevNetworkLogKind.serverError:
        return Colors.red;
      case DevNetworkLogKind.networkError:
        return Colors.deepOrangeAccent;
    }
  }
}

class _DevMenuInfoTab extends StatefulWidget {
  const _DevMenuInfoTab();

  @override
  State<_DevMenuInfoTab> createState() => _DevMenuInfoTabState();
}

class _DevMenuInfoTabState extends State<_DevMenuInfoTab> {
  static final DevLogger _logger = DevLogger('DevMenuInfo');
  
  PackageInfo? _packageInfo;
  String _deviceInfo = '';
  bool _deviceInfoError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      // Load package info with timeout
      PackageInfo? info;
      try {
        info = await PackageInfo.fromPlatform().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('PackageInfo.fromPlatform timed out');
          },
        );
      } catch (e) {
        if (!mounted) return;
        _logger.warning('PackageInfo load failed: $e');
        info = null;
      }

      if (!mounted) return;

      // Load device info with timeout
      var devInfo = '';
      var hasDeviceError = false;

      try {
        final deviceInfoPlugin = DeviceInfoPlugin();

        if (Platform.isAndroid) {
          final androidInfo = await deviceInfoPlugin.androidInfo.timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('androidInfo call timed out');
            },
          );
          final abis = androidInfo.supportedAbis
              .where((abi) => abi.isNotEmpty)
              .join(', ');
          devInfo = [
            '${androidInfo.manufacturer} ${androidInfo.model}'.trim(),
            'Android ${androidInfo.version.release} • SDK ${androidInfo.version.sdkInt}',
            '${androidInfo.device} • ${androidInfo.product}',
            if (abis.isNotEmpty) abis,
          ].where((line) => line.trim().isNotEmpty).join('\n');
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo.timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('iosInfo call timed out');
            },
          );
          devInfo = [
            iosInfo.name,
            '${iosInfo.model} • ${iosInfo.systemName} ${iosInfo.systemVersion}',
          ].where((line) => line.trim().isNotEmpty).join('\n');
        } else {
          devInfo = [
            Platform.localHostname,
            Platform.operatingSystem,
            Platform.operatingSystemVersion,
          ].where((line) => line.trim().isNotEmpty).join('\n');
        }
      } on TimeoutException catch (e) {
        if (!mounted) return;
        _logger.warning('Device info collection timed out: $e');
        hasDeviceError = true;
        devInfo = '[Device info collection timeout after 5 seconds]';
      } catch (e) {
        if (!mounted) return;
        _logger.error('Device info collection failed: $e');
        hasDeviceError = true;
        devInfo = '[Device info collection failed: $e]';
      }

      if (!mounted) return;

      setState(() {
        _packageInfo = info;
        _deviceInfo = devInfo;
        _deviceInfoError = hasDeviceError;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      _logger.error('Failed to load app info: $e');
      setState(() {
        _packageInfo = null;
        _errorMessage = 'Failed to load app info: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_packageInfo == null && _errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(UITokens.spaceMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: UITokens.spaceMd),
              Text(
                _errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: UITokens.spaceMd),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _packageInfo = null;
                    _deviceInfo = '';
                    _deviceInfoError = false;
                    _errorMessage = null;
                  });
                  _loadInfo();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_packageInfo == null) {
      return AppLoadingState(label: l10n.devMenuInfoLoading);
    }

    return ListView(
      padding: const EdgeInsets.all(UITokens.spaceMd),
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.devMenuAppNameLabel),
          subtitle: Text(_packageInfo!.appName),
        ),
        ListTile(
          leading: const Icon(Icons.numbers),
          title: Text(l10n.devMenuVersionLabel),
          subtitle: Text(
            l10n.devMenuVersionWithBuild(
              _packageInfo!.version,
              _packageInfo!.buildNumber,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: Text(l10n.devMenuPackageNameLabel),
          subtitle: Text(_packageInfo!.packageName),
        ),
        ListTile(
          leading: _deviceInfoError 
              ? const Icon(Icons.warning, color: Colors.orange)
              : const Icon(Icons.phone_android),
          title: Text(l10n.devMenuDeviceLabel),
          subtitle: Text(_deviceInfo.isEmpty ? l10n.noData : _deviceInfo),
          trailing: _deviceInfoError
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadInfo,
                  tooltip: 'Retry device info',
                )
              : null,
        ),
      ],
    );
  }
}
