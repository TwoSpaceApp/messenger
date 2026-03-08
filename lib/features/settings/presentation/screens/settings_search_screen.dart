import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/highlighted_text.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

class SettingsSearchScreen extends StatefulWidget {
  const SettingsSearchScreen({super.key});

  @override
  State<SettingsSearchScreen> createState() => _SettingsSearchScreenState();
}

class _SettingsSearchScreenState extends State<SettingsSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _sectionFilter;

  static final List<_SettingsSearchEntry> _entries = [
    _SettingsSearchEntry(
      title: 'Оформление',
      subtitle: 'Тема приложения',
      section: 'Внешний вид',
      keywords: ['dark', 'light', 'theme', 'appearance', 'цвет'],
      onTap: (context) async {
        context.pop();
      },
    ),
    _SettingsSearchEntry(
      title: 'Кастомизация',
      subtitle: 'Шрифты, цвета, анимации интерфейса',
      section: 'Внешний вид',
      keywords: ['font', 'color', 'ui', 'customization', 'bubble'],
      onTap: (context) async {
        context.push('/customization');
      },
    ),
    _SettingsSearchEntry(
      title: 'Уведомления',
      subtitle: 'Новые сообщения и режим не беспокоить',
      section: 'Уведомления',
      keywords: ['notification', 'mute', 'dnd', 'sound'],
      onTap: (context) async {
        context.push('/notifications');
      },
    ),
    _SettingsSearchEntry(
      title: 'Профиль',
      subtitle: 'Открыть ваш профиль',
      section: 'Аккаунт',
      keywords: ['profile', 'user', 'avatar', 'name'],
      onTap: (context) async {
        final userId = await AuthService().getCurrentUserId();
        if (context.mounted && userId != null) {
          context.push('/profile', extra: userId);
        }
      },
    ),
    _SettingsSearchEntry(
      title: 'Настройки аккаунта',
      subtitle: 'Управление данными аккаунта',
      section: 'Аккаунт',
      keywords: ['account', 'email', 'phone'],
      onTap: (context) async {
        context.push('/account-settings');
      },
    ),
    _SettingsSearchEntry(
      title: 'Приватность',
      subtitle: 'Видимость данных и защита аккаунта',
      section: 'Аккаунт',
      keywords: ['privacy', 'security', '2fa', 'visibility'],
      onTap: (context) async {
        context.push('/privacy');
      },
    ),
    _SettingsSearchEntry(
      title: 'Язык',
      subtitle: 'Переключение языка интерфейса',
      section: 'Общие',
      keywords: ['language', 'locale', 'translation'],
      onTap: (context) async {
        context.pop();
      },
    ),
    _SettingsSearchEntry(
      title: 'Отправка по Enter',
      subtitle: 'Быстрая отправка сообщений клавишей Enter',
      section: 'Общие',
      keywords: ['enter', 'keyboard', 'send'],
      onTap: (context) async {
        context.pop();
      },
    ),
    _SettingsSearchEntry(
      title: 'Автозагрузка медиа',
      subtitle: 'Автоматическая загрузка медиафайлов',
      section: 'Хранение',
      keywords: ['media', 'download', 'auto', 'files'],
      onTap: (context) async {
        context.pop();
      },
    ),
    _SettingsSearchEntry(
      title: 'Память',
      subtitle: 'Использование памяти и размер данных',
      section: 'Хранение',
      keywords: ['storage', 'memory', 'cache', 'space'],
      onTap: (context) async {
        context.push('/storage');
      },
    ),
    _SettingsSearchEntry(
      title: 'Управление хранилищем',
      subtitle: 'Очистка кеша и локальных данных',
      section: 'Хранение',
      keywords: ['clear', 'cache', 'storage'],
      onTap: (context) async {
        context.pop();
      },
    ),
    _SettingsSearchEntry(
      title: 'О приложении',
      subtitle: 'Версия клиента и обратная связь',
      section: 'О приложении',
      keywords: ['about', 'version', 'feedback'],
      onTap: (context) async {
        context.pop();
      },
    ),
    _SettingsSearchEntry(
      title: 'Предложить улучшение',
      subtitle: 'Отправить отзыв о приложении',
      section: 'О приложении',
      keywords: ['feedback', 'improve', 'suggestion'],
      onTap: (context) async {
        context.push('/feedback');
      },
    ),
  ];

  List<String> get _sections =>
      _entries.map((entry) => entry.section).toSet().toList()..sort();

  List<_SettingsSearchEntry> get _filteredEntries {
    final query = _query.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesSection = _sectionFilter == null || entry.section == _sectionFilter;
      if (!matchesSection) return false;
      if (query.isEmpty) return true;
      return entry.searchText.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Scaffold(
      appBar: AppBar(title: const Text('Поиск по настройкам')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Искать раздел, настройку или действие',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Все'),
                      selected: _sectionFilter == null,
                      onSelected: (_) => setState(() => _sectionFilter = null),
                    ),
                  ),
                  ..._sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(section),
                        selected: _sectionFilter == section,
                        onSelected: (_) => setState(() => _sectionFilter = section),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: entries.isEmpty
                    ? const AppEmptyState(
                      key: ValueKey('empty-settings-search'),
                        title: 'Ничего не найдено',
                        message:
                            'Попробуйте другой запрос или снимите фильтр по разделу.',
                        icon: Icons.manage_search_rounded,
                      )
                    : ListView.separated(
                        key: ValueKey('${_query}_${_sectionFilter ?? 'all'}'),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.12),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: HighlightedText(
                                entry.title,
                                query: _query,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  HighlightedText(
                                    entry.subtitle,
                                    query: _query,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.72),
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.09),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      entry.section,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => entry.onTap(context),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSearchEntry {
  const _SettingsSearchEntry({
    required this.title,
    required this.subtitle,
    required this.section,
    required this.keywords,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String section;
  final List<String> keywords;
  final Future<void> Function(BuildContext context) onTap;

  String get searchText => '$title $subtitle $section ${keywords.join(' ')}'.toLowerCase();
}
