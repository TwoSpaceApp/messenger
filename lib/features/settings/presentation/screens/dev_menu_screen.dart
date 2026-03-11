import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';
import 'package:two_space_app/core/services/dev_tools_service.dart';
import 'package:two_space_app/core/services/update_service.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/highlighted_text.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/settings/presentation/screens/dev_screen_catalog.dart';

class FeatureFlags {
  static final ValueNotifier<bool> enableNewChatUI = ValueNotifier(false);
  static final ValueNotifier<bool> forceVideoCompression = ValueNotifier(true);
  static final ValueNotifier<bool> enableAggressiveCaching = ValueNotifier(false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Developer Menu'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_customize_outlined), text: 'Actions'),
            Tab(icon: Icon(Icons.brush_outlined), text: 'UI Inspect'),
            Tab(icon: Icon(Icons.article_outlined), text: 'Logs'),
            Tab(icon: Icon(Icons.network_check), text: 'Network'),
            Tab(icon: Icon(Icons.flag_outlined), text: 'Features'),
            Tab(icon: Icon(Icons.info_outline), text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: DevLogger.stream,
      initialData: DevLogger.all,
      builder: (context, snapshot) {
        final sourceLogs = snapshot.data ?? const <String>[];
        final logs = _showOnlyErrors
            ? sourceLogs.where((line) => line.contains(LogLevel.error.emoji)).toList()
            : sourceLogs;

        if (logs.isEmpty) {
          return AppEmptyState(
            title: 'Пока нет логов приложения',
            message:
                'Откройте проблемный экран или повторите действие — новые записи появятся здесь.',
            icon: Icons.receipt_long_outlined,
            actionLabel: sourceLogs.isNotEmpty ? 'Показать всё' : null,
            onAction: sourceLogs.isNotEmpty
                ? () => setState(() => _showOnlyErrors = false)
                : null,
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      _showOnlyErrors
                          ? 'Только ошибки'
                          : 'Все записи (${sourceLogs.length})',
                    ),
                    selected: _showOnlyErrors,
                    onSelected: (value) => setState(() => _showOnlyErrors = value),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: DevLogger.clear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Очистить'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final line = logs[index];
                  final color = _appLogColor(line);
                  return Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.18)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
    final groupedScreens = _groupedScreens;
    final query = _searchController.text.trim();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(context, 'Screen Explorer'),
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Поиск по имени, группе или файлу экрана',
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
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('Все (${_allScreens.length})'),
                  selected: _selectedGroup == null,
                  onSelected: (_) => setState(() => _selectedGroup = null),
                ),
              ),
              ..._groups.map(
                (group) {
                  final count = _allScreens.where((e) => e.group == group).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
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
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: groupedScreens.isEmpty
              ? const AppEmptyState(
                  key: ValueKey('empty-dev-screens'),
                  title: 'Экраны не найдены',
                  message: 'Измените поисковый запрос или снимите фильтр группы.',
                  icon: Icons.travel_explore_rounded,
                )
              : Container(
                  key: ValueKey('${query}_${_selectedGroup ?? 'all'}'),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (final entry in groupedScreens.entries) ...[
                        _buildGroupHeader(context, entry.key, entry.value.length),
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
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Utilities'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildAction(
              context,
              '💥 Force Crash',
              Icons.bug_report_outlined,
              () => throw Exception('Test crash triggered from Dev Menu'),
              color: Colors.orange,
            ),
            _buildAction(
              context,
              '🗑️ Clear Secure Storage',
              Icons.delete_forever_outlined,
              () async {
                const storage = FlutterSecureStorage();
                await storage.deleteAll();
                widget.logger.info('Secure storage cleared');
              },
              color: Colors.red,
            ),
            _buildAction(
              context,
              '🗂️ Clear Cache Profile',
              Icons.layers_clear,
              () async {
                await SettingsService.clearCachedProfile();
                widget.logger.info('Profile cache cleared');
              },
              color: Colors.red,
            ),
            _buildAction(
              context,
              'OTA Check',
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
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
          const SizedBox(height: 4),
          HighlightedText(
            entry.source,
            query: query,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Открыть экран',
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
      padding: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Показывать границы (debugPaintSize)'),
          subtitle: const Text('Отображение отступов и границ всех виджетов'),
          value: debugPaintSizeEnabled,
          onChanged: (val) => setState(() => debugPaintSizeEnabled = val),
        ),
        SwitchListTile(
          title: const Text('Закрашивать перерисовки (RepaintRainbow)'),
          subtitle:
              const Text('Подсвечивает элементы, которые перерисовываются'),
          value: debugRepaintRainbowEnabled,
          onChanged: (val) => setState(() => debugRepaintRainbowEnabled = val),
        ),
        SwitchListTile(
          title: const Text('Медленные анимации (timeDilation = 5.0)'),
          subtitle: const Text('Замедляет все анимации в приложении'),
          value: timeDilation != 1.0,
          onChanged: (val) => setState(() => timeDilation = val ? 5.0 : 1.0),
        ),
        SwitchListTile(
          title: const Text('Профилирование производительности'),
          subtitle: const Text('Отображает Performance Overlay сверху'),
          value: DevToolsService.performanceOverlayEnabled.value,
          onChanged: (val) => setState(
            () => DevToolsService.performanceOverlayEnabled.value = val,
          ),
        ),
      ],
    );
  }
}

class _DevMenuFeatureFlagsTab extends StatelessWidget {
  const _DevMenuFeatureFlagsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFlagTile('Enable New Chat UI', FeatureFlags.enableNewChatUI),
        _buildFlagTile(
            'Force Video Compression', FeatureFlags.forceVideoCompression),
        _buildFlagTile(
            'Enable Aggressive Caching', FeatureFlags.enableAggressiveCaching),
        _buildFlagTile(
          'Ignore Server Offline (no logout)',
          FeatureFlags.ignoreServerOffline,
          subtitle:
              'Сохраняет текущую сессию и не выбрасывает на экран входа, если сервер недоступен.',
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DevNetworkLog>>(
      stream: DevNetworkLogger.instance.logsStream,
      initialData: DevNetworkLogger.instance.logs,
      builder: (context, snapshot) {
        final sourceLogs = snapshot.data ?? [];
        final logs = _showOnlyErrors
            ? sourceLogs.where((log) => log.isError).toList()
            : sourceLogs;

        if (logs.isEmpty) {
          return AppEmptyState(
            title: 'Пока нет сетевых логов',
            message:
                'Откройте любой экран, который делает запросы, и логи появятся здесь.',
            icon: Icons.wifi_find_rounded,
            actionLabel: sourceLogs.isNotEmpty ? 'Показать всё' : null,
            onAction: sourceLogs.isNotEmpty
                ? () => setState(() => _showOnlyErrors = false)
                : null,
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(_showOnlyErrors
                        ? 'Только ошибки'
                        : 'Все запросы (${sourceLogs.length})'),
                    selected: _showOnlyErrors,
                    onSelected: (value) => setState(() => _showOnlyErrors = value),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: DevNetworkLogger.instance.clear,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Очистить'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final color = _colorFor(log);

                  return ColoredBox(
                    color: color.withValues(alpha: 0.035),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
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
                          _buildMetaChip('${log.latencyMs} ms', Colors.blueGrey),
                          _buildMetaChip(log.responseTypeLabel, Colors.deepPurple),
                        ],
                      ),
                      children: [
                        _buildDetailsHeader(log, color),
                        if (log.requestHeaders.isNotEmpty)
                          _buildCodeBlock(
                            'Request headers',
                            log.requestHeaders,
                            accent: Colors.lightBlueAccent,
                          ),
                        if (log.requestBody != null)
                          _buildCodeBlock(
                            'Request body · ${log.requestTypeLabel}',
                            log.requestBody,
                            accent: Colors.orangeAccent,
                          ),
                        if (log.responseHeaders.isNotEmpty)
                          _buildCodeBlock(
                            'Response headers',
                            log.responseHeaders,
                            accent: Colors.cyanAccent,
                          ),
                        if (log.responseBody != null || log.errorMessage != null)
                          _buildCodeBlock(
                            'Response body · ${log.responseTypeLabel}',
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

  Widget _buildDetailsHeader(DevNetworkLog log, Color color) {
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
            log.isError ? 'problem detected' : 'completed',
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
        borderRadius: BorderRadius.circular(999),
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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
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
  PackageInfo? _packageInfo;
  String _deviceInfo = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await PackageInfo.fromPlatform();
    final deviceInfoPlugin = DeviceInfoPlugin();
    var devInfo = '';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      devInfo =
          '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      devInfo = '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
    }

    if (!mounted) return;
    setState(() {
      _packageInfo = info;
      _deviceInfo = devInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_packageInfo == null) {
      return const AppLoadingState(label: 'Собираем сведения об устройстве…');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('App Name'),
          subtitle: Text(_packageInfo!.appName),
        ),
        ListTile(
          leading: const Icon(Icons.numbers),
          title: const Text('Version'),
          subtitle:
              Text('${_packageInfo!.version} (Build ${_packageInfo!.buildNumber})'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Package Name'),
          subtitle: Text(_packageInfo!.packageName),
        ),
        ListTile(
          leading: const Icon(Icons.phone_android),
          title: const Text('Device'),
          subtitle: Text(_deviceInfo),
        ),
      ],
    );
  }
}
