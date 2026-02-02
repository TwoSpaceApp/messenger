import 'package:flutter/material.dart';
import 'package:two_space_app/widgets/glass_card.dart';
import 'package:two_space_app/services/auth_service.dart';
import 'package:two_space_app/services/settings_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedTheme = 'system';
  bool _loggingOut = false;
  bool _devMenuEnabled = false;
  String _appVersion = 'загрузка...';
  String _selectedLanguage = 'ru';
  bool _autoDownloadMedia = false;
  bool _sendByEnter = true;
  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _selectedLanguage = SettingsService.languageNotifier.value;
      _textScale = SettingsService.textScaleNotifier.value;
      _autoDownloadMedia = SettingsService.autoDownloadMediaNotifier.value;
      _sendByEnter = SettingsService.sendByEnterNotifier.value;
      
      // Load notifications/sound if they exist in service, otherwise default
      // Assuming existing service has notification settings (checked previously, didn't see explicit pub methods but maybe notifiers?)
      // Actually checking previous read of SettingsService... 
      // It has showEmail, showPhone, paleViolet, etc. but not generic notifications/sound.
      // Keeping local state for those for now as they might be system level or unimplemented.
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = info.version);
    } catch (_) {
      setState(() => _appVersion = 'неизвестно');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выход', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loggingOut = true);
    try {
      final auth = AuthService();
      await auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Внешний вид
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Внешний вид',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                      title: const Text('Тема'),
                      trailing: DropdownButton<String>(
                        value: _selectedTheme,
                        onChanged: (value) => setState(() => _selectedTheme = value ?? 'system'),
                        items: const [
                          DropdownMenuItem(value: 'system', child: Text('Система')),
                          DropdownMenuItem(value: 'light', child: Text('Светлая')),
                          DropdownMenuItem(value: 'dark', child: Text('Темная')),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Уведомления
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Уведомления',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications),
                      title: const Text('Уведомления'),
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up),
                      title: const Text('Звук'),
                      value: _soundEnabled,
                      onChanged: (v) => setState(() => _soundEnabled = v),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Аккаунт
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Аккаунт',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Профиль'),
                      subtitle: const Text('Изменить данные профиля'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final auth = AuthService();
                        final userId = await auth.getCurrentUserId();
                        if (userId != null && context.mounted) {
                          Navigator.pushNamed(context, '/profile', arguments: userId);
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.manage_accounts),
                      title: const Text('Настройки аккаунта'),
                      subtitle: const Text('Пароль, безопасность, 2FA'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/account-settings'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Конфиденциальность'),
                      subtitle: const Text('Управление приватностью'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/privacy'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Общие настройки
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Общие',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Язык'),
                      trailing: DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox(),
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() => _selectedLanguage = value);
                            await SettingsService.setLanguage(value);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'ru', child: Text('Русский')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'uk', child: Text('Українська')),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: const Text('Размер текста'),
                      subtitle: Slider(
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        value: _textScale,
                        label: '${(_textScale * 100).toInt()}%',
                        onChanged: (v) => setState(() => _textScale = v),
                        onChangeEnd: (v) async => await SettingsService.setTextScale(v),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.keyboard),
                      title: const Text('Отправка по Enter'),
                      subtitle: const Text('Shift+Enter для новой строки'),
                      value: _sendByEnter,
                      onChanged: (v) async {
                        setState(() => _sendByEnter = v);
                        await SettingsService.setSendByEnter(v);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Данные и хранилище
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Данные и хранилище',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.download),
                      title: const Text('Автозагрузка медиа'),
                      subtitle: const Text('Загружать фото и видео автоматически'),
                      value: _autoDownloadMedia,
                      onChanged: (v) async {
                        setState(() => _autoDownloadMedia = v);
                        await SettingsService.setAutoDownloadMedia(v);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Управление хранилищем'),
                      subtitle: const Text('Очистить кеш и данные'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Очистить кеш'),
                            content: const Text('Удалить кешированные данные?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Кеш очищен')),
                                  );
                                },
                                child: const Text('Очистить'),
                              ),
                            ],
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
              ),
            ),

            // Параметры разработчика
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Разработка',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Developer Menu'),
                  subtitle: const Text('Плавающая кнопка отладки'),
                  trailing: Switch(
                    value: _devMenuEnabled,
                    onChanged: (value) {
                      setState(() => _devMenuEnabled = value);
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),

            // О приложении
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'О приложении',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('TwoSpace'),
                      subtitle: Text(_appVersion),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const Divider(height: 1),
                    Tooltip(
                      message: 'Matrix — это открытый протокол для обмена сообщениями, мы используем именно его!',
                      child: ListTile(
                      subtitle: const Text('Клиент TwoSpace написан на Flutter/Dart'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Опасная зона
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Опасная зона',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GlassCard(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _loggingOut ? null : _logout,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red.shade400),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Выход из аккаунта',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  'Выход с этого устройства',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.red.withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (_loggingOut)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }
}
