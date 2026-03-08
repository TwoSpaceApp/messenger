import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';
import 'package:two_space_app/core/services/update_service.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:two_space_app/features/auth/presentation/screens/login_screen.dart';
import 'package:two_space_app/features/auth/presentation/screens/register_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/home_screen.dart';
import 'package:two_space_app/features/settings/presentation/screens/customization_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Флаги фичей для локального тестирования
class FeatureFlags {
  static final ValueNotifier<bool> enableNewChatUI = ValueNotifier(false);
  static final ValueNotifier<bool> forceVideoCompression = ValueNotifier(true);
  static final ValueNotifier<bool> enableAggressiveCaching = ValueNotifier(false);
}

class DevMenuScreen extends StatefulWidget {
  const DevMenuScreen({super.key});

  @override
  State<DevMenuScreen> createState() => _DevMenuScreenState();
}

class _DevMenuScreenState extends State<DevMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DevLogger _logger = DevLogger('DevMenu');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
            Tab(icon: Icon(Icons.build), text: 'Actions'),
            Tab(icon: Icon(Icons.brush), text: 'UI Inspect'),
            Tab(icon: Icon(Icons.network_check), text: 'Network'),
            Tab(icon: Icon(Icons.flag), text: 'Features'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DevMenuActionsTab(logger: _logger),
          _DevMenuUIInspectorTab(),
          _DevMenuNetworkTab(),
          _DevMenuFeatureFlagsTab(),
          _DevMenuInfoTab(),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// ACTIONS TAB
// ----------------------------------------------------------------------
class _DevMenuActionsTab extends StatelessWidget {
  final DevLogger logger;
  const _DevMenuActionsTab({required this.logger});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle(context, 'Navigation Bypass'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildAction(context, '🏠 Force to Home', Icons.home, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            }, color: Colors.green),
            _buildAction(context, '🔑 Force to Login', Icons.login, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            }),
            _buildAction(context, '📝 Force to Register', Icons.app_registration, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
            }),
            _buildAction(context, '🎨 Customization', Icons.color_lens, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizationScreen()));
            }),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildSectionTitle(context, 'Testing & Load Gen'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildAction(context, '💥 Force Crash', Icons.bug_report, () {
              throw Exception('Test Crash triggered from Dev Menu');
            }, color: Colors.orange),
            _buildAction(context, '🔥 1000 Mock Messages', Icons.data_array, () {
               // Здесь в будущем можно вызывать сервис добавления моков в базу
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Load Gen: Added 1000 mock messages (simulated)')));
            }, color: Colors.orange),
             _buildAction(context, 'Обновить OTA', Icons.system_update, () async {
              logger.info('Обновление...');
              await UpdateService.checkForUpdate();
            }),
          ],
        ),
        const SizedBox(height: 24),

        _buildSectionTitle(context, 'Storage & State'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildAction(context, '🗑️ Clear Secure Storage', Icons.delete_forever, () async {
              const storage = FlutterSecureStorage();
              await storage.deleteAll();
              logger.info('Secure storage cleared');
            }, color: Colors.red),
            _buildAction(context, '🗂️ Clear Cache Profile', Icons.layers_clear, () async {
              await SettingsService.clearCachedProfile();
              logger.info('Profile cache cleared');
            }, color: Colors.red),
          ],
        ),
      ],
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

  Widget _buildAction(BuildContext context, String label, IconData icon, VoidCallback onTap, {Color? color}) {
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

// ----------------------------------------------------------------------
// UI INSPECTOR TAB
// ----------------------------------------------------------------------
class _DevMenuUIInspectorTab extends StatefulWidget {
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
          onChanged: (val) {
            setState(() {
              debugPaintSizeEnabled = val;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Закрашивать перерисовки (RepaintRainbow)'),
          subtitle: const Text('Подсвечивает элементы, которые перерисовываются'),
          value: debugRepaintRainbowEnabled,
          onChanged: (val) {
            setState(() {
              debugRepaintRainbowEnabled = val;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Медленные анимации (timeDilation = 5.0)'),
          subtitle: const Text('Замедляет все анимации в приложении'),
          value: timeDilation != 1.0,
          onChanged: (val) {
            setState(() {
              timeDilation = val ? 5.0 : 1.0;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Профилирование производительности'),
          subtitle: const Text('Отображает Performance Overlay сверху'),
          value: WidgetsApp.showPerformanceOverlayOverride,
          onChanged: (val) {
            setState(() {
               WidgetsApp.showPerformanceOverlayOverride = val;
            });
          },
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// FEATURE FLAGS TAB
// ----------------------------------------------------------------------
class _DevMenuFeatureFlagsTab extends StatefulWidget {
  @override
  State<_DevMenuFeatureFlagsTab> createState() => _DevMenuFeatureFlagsTabState();
}

class _DevMenuFeatureFlagsTabState extends State<_DevMenuFeatureFlagsTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFlagTile('Enable New Chat UI', FeatureFlags.enableNewChatUI),
        _buildFlagTile('Force Video Compression', FeatureFlags.forceVideoCompression),
        _buildFlagTile('Enable Aggressive Caching', FeatureFlags.enableAggressiveCaching),
      ],
    );
  }

  Widget _buildFlagTile(String title, ValueNotifier<bool> flag) {
    return ValueListenableBuilder<bool>(
      valueListenable: flag,
      builder: (context, value, child) {
        return SwitchListTile(
          title: Text(title),
          value: value,
          onChanged: (val) => flag.value = val,
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// NETWORK TAB
// ----------------------------------------------------------------------
class _DevMenuNetworkTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DevNetworkLog>>(
      stream: DevNetworkLogger.instance.logsStream,
      initialData: DevNetworkLogger.instance.logs,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 64, color: Colors.grey.withAlpha(128)),
                const SizedBox(height: 16),
                const Text('No Network Logs', style: TextStyle(color: Colors.grey)),
              ],
            )
          );
        }
        return ListView.separated(
          itemCount: logs.length,
          separatorBuilder: (c, i) => const Divider(height: 1),
          itemBuilder: (c, index) {
            final log = logs[index];
            final color = (log.statusCode ?? 0) >= 400 ? Colors.red : Colors.green;
            return ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withAlpha(50), borderRadius: BorderRadius.circular(8)),
                child: Text(log.method, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              title: Text(log.url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              subtitle: Text('${log.statusCode ?? '???'} • ${log.latencyMs}ms', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              children: [
                if (log.requestBody != null)
                  _buildCodeBlock('Request', log.requestBody),
                if (log.responseBody != null)
                  _buildCodeBlock('Response', log.responseBody),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCodeBlock(String title, dynamic data) {
    String pretty = '';
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(pretty, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// INFO TAB
// ----------------------------------------------------------------------
class _DevMenuInfoTab extends StatefulWidget {
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
    String devInfo = '';
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      devInfo = '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      devInfo = '${iosInfo.name} (iOS ${iosInfo.systemVersion})';
    }

    setState(() {
      _packageInfo = info;
      _deviceInfo = devInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_packageInfo == null) return const Center(child: CircularProgressIndicator());

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
          subtitle: Text('${_packageInfo!.version} (Build ${_packageInfo!.buildNumber})'),
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
